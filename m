Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38541 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754302Ab3BPWai (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 16 Feb 2013 17:30:38 -0500
Date: Sat, 16 Feb 2013 17:30:35 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 10/15] NFS: Client implementation of Labeled-NFS
Message-ID: <20130216223035.GB28824@fieldses.org>
References: <1360327163-20360-1-git-send-email-SteveD@redhat.com>
 <1360327163-20360-11-git-send-email-SteveD@redhat.com>
 <20130212230346.GN10267@fieldses.org>
 <511FED8E.7020308@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <511FED8E.7020308@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Feb 16, 2013 at 03:35:26PM -0500, Steve Dickson wrote:
> On 12/02/13 18:03, J. Bruce Fields wrote:
> >> +static int decode_attr_security_label(struct xdr_stream *xdr, uint32_t *bitmap,
> >> > +					struct nfs4_label *label)
> >> > +{
> >> > +	uint32_t pi = 0;
> >> > +	uint32_t lfs = 0;
> >> > +	__u32 len;
> >> > +	__be32 *p;
> >> > +	int status = 0;
> >> > +
> >> > +	if (unlikely(bitmap[2] & (FATTR4_WORD2_SECURITY_LABEL - 1U)))
> >> > +		return -EIO;
> >> > +	if (likely(bitmap[2] & FATTR4_WORD2_SECURITY_LABEL)) {
> >> > +		p = xdr_inline_decode(xdr, 4);
> >> > +		if (unlikely(!p))
> >> > +			goto out_overflow;
> >> > +		lfs = be32_to_cpup(p++);
> >> > +		p = xdr_inline_decode(xdr, 4);
> >> > +		if (unlikely(!p))
> >> > +			goto out_overflow;
> >> > +		pi = be32_to_cpup(p++);
> >> > +		p = xdr_inline_decode(xdr, 4);
> >> > +		if (unlikely(!p))
> >> > +			goto out_overflow;
> >> > +		len = be32_to_cpup(p++);
> >> > +		p = xdr_inline_decode(xdr, len);
> >> > +		if (unlikely(!p))
> >> > +			goto out_overflow;
> >> > +		if (len < XDR_MAX_NETOBJ) {
> >> > +			if (label) {
> >> > +				nfs4_label_init(label);
> >> > +				if (label->len < len) {
> > If I remember the earlier patch right, nfs4_label_init() just set
> > label->len to NFS4_MAXLABELLEN.
> Good good catch... XDR_MAX_NETOBJ should be NFS4_MAXLABELLEN.
> 
> > 
> > Doesn't that overwrite the length that was passed into
> > nfs4_get_security_label?
> Yes... the len will be set to the actual size of the label which
> will be less than NFS4_MAXLABELLEN. So I'm thinking this overwrite 
> of the is fine.
> 
> This is the reason nfs4_label_init() resets len to NFS4_MAXLABELLEN

OK, but then
					if (label->len < len)
is equivalent to
					if (NFS4_MAXLABELLEN < len)
Why are we checking len twice?

You may want to just remove nfs4_label_init() entirely.  This is the
only caller, and it doesn't seem very useful.

--b.
