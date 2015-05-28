Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:53757 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754220AbbE1Udd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 May 2015 16:33:33 -0400
Date: Thu, 28 May 2015 16:33:32 -0400
To: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC v3 36/45] NFSv4: Fix GETATTR bitmap verification
Message-ID: <20150528203332.GD31663@fieldses.org>
References: <cover.1429868795.git.agruenba@redhat.com>
 <8d601ee8babe5239b7926542c713c58502b15e35.1429868795.git.agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <8d601ee8babe5239b7926542c713c58502b15e35.1429868795.git.agruenba@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 24, 2015 at 01:04:33PM +0200, Andreas Gruenbacher wrote:
> The NFSv4 client sends the server GETATTR requests with different sets of
> requested attributes depending on the situation.  The requested set of
> attributes is encoded in a bitmap; the server replies with the set of
> attributes it could return.  These bitmaps can be several words wide.  The
> bitmap returned by the server is a subset of the bitmap sent by the client.
> 
> While decoding the reply, the client tries to verify the reply bitmap: it
> checks if any previous, unexpected attributes are left in the same word of the
> bitmap for each attribute it tries to decode, then it clears the current
> attribute's bit in the bitmap for the next decode function.
> 
> The client fails to detect when unexpected attributes are sent after the last
> expected attribute in each word in the bitmap.

Is it important that the client catch that?

> Fix this by checking the entire bitmap for unexpected attributes first.  The
> server can still send attributes which the client understands but which it
> didn't request; this doesn't cause any harm.

I don't understand that last sentence.  On a skim it looks like after
this patch we *will* still error out if a server does that, right?  (As
we should, that would be a server bug.)

...
> +static int verify_attrs_allowed(uint32_t *bitmap, const uint32_t *attrs_allowed)
> +{
> +	if (unlikely(bitmap[0] & ~attrs_allowed[0] ||
> +		     bitmap[1] & ~attrs_allowed[1] ||
> +		     bitmap[2] & ~attrs_allowed[2]))
> +		return -EIO;
> +	return 0;
> +}
> +
>  static int decode_change_info(struct xdr_stream *xdr, struct nfs4_change_info *cinfo)
>  {
>  	__be32 *p;
> @@ -4296,6 +4195,11 @@ out_overflow:
>  
>  static int decode_server_caps(struct xdr_stream *xdr, struct nfs4_server_caps_res *res)
>  {
> +	static const uint32_t attrs_allowed[3] = {
> +		[0] = FATTR4_WORD0_SUPPORTED_ATTRS | FATTR4_WORD0_FH_EXPIRE_TYPE |
> +		      FATTR4_WORD0_LINK_SUPPORT | FATTR4_WORD0_SYMLINK_SUPPORT |
> +		      FATTR4_WORD0_ACLSUPPORT,
> +	};

This is the same list as in nfs4-xdr_enc_server_caps.  Could we avoid
that duplication?

--b.
