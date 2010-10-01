Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55479 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932412Ab0JAPUq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Oct 2010 11:20:46 -0400
Date: Fri, 1 Oct 2010 11:20:32 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsd41: mask out unsupported pnfs attributes
Message-ID: <20101001152032.GF17310@fieldses.org>
References: <1285872478-21045-1-git-send-email-bhalevy@panasas.com>
 <20101001144847.GC17310@fieldses.org>
 <4CA5FB9F.1030508@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CA5FB9F.1030508@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Oct 01, 2010 at 05:17:51PM +0200, Benny Halevy wrote:
> On 2010-10-01 16:48,  J. Bruce Fields wrote:
> > On Thu, Sep 30, 2010 at 08:47:58PM +0200, Benny Halevy wrote:
> >> These attributes are valid in NFSv4.1, the just doesn't support them yet.
> > 
> > The existing code handles unsupported attributes in the operations
> > themselves.  Perhaps it makes sense to move those checks here, but if
> > so, explain why, and let's do this for all unsupported attributes, not
> > just these two.
> 
> The client can run a DOS attack on the server by requesting invalid attributes
> and tripping the BUG_ONs in nfsd4_encode_fattr.

How can they do that?  getattr and readdir, for example, both handle
this.  But I may well be missing something!

> We can/should also change the BUG_ONs to either report invalid
> attribute or just silently ignore them, but the client is
> perfectly entitled to get attrs we don't support :)

Sure.

> > Looking back at the spec....  I guess it's only on operations that set
> > attributes that we return NFS4ERR_ATTRNOTSUPP, and otherwise we silently
> > ignore them?
> 
> For the GETATTR case, we just return the attrmask for the attrs we support.
> IOW:
>    The server returns an attribute bitmap that
>    indicates the attribute values that it was able to return, which will
>    include all attributes requested by the client that are attributes
>    supported by the server for the target file system.

OK, makes sense.

--b.
