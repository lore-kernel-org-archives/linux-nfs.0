Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15590 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751265Ab2HBLN4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Aug 2012 07:13:56 -0400
Message-ID: <1343906031.2118.22.camel@localhost>
Subject: Re: [PATCH 2/2] Simplify check for size of ACL returned in
 __nfs4_get_acl_uncached
From: Sachin Prabhu <sprabhu@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Date: Thu, 02 Aug 2012 12:13:51 +0100
In-Reply-To: <1343843776.9097.10.camel@lade.trondhjem.org>
References: <1343827771-6258-1-git-send-email-sprabhu@redhat.com>
	 <1343827771-6258-3-git-send-email-sprabhu@redhat.com>
	 <1343843776.9097.10.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2012-08-01 at 17:56 +0000, Myklebust, Trond wrote:
>  
> >  	acl_len = res.acl_len - res.acl_data_offset;
> > -	if (res.acl_len > args.acl_len)
> > +	if (res.acl_flags & NFS4_ACL_LEN_ONLY)
> 
> Is this a bugfix or a cleanup? If the former, then it belongs in the
> first patch.

The earlier patch fixes this bug with the the if condition. This patch
introduces the NFS4_ACL_LEN_ONLY flag which is set when the buffer we
have set aside for the ACLs was not enough for the ACLs returned by the
server.

> 
> >  		nfs4_write_cached_acl(inode, NULL, 0, acl_len);
> >  	else
> >  		nfs4_write_cached_acl(inode, pages, res.acl_data_offset,
> 
> Now if NFS4_ACL_LEN_ONLY is set, we appear to unconditionally write the
> acl, even if the buffer overflows...

If NFS4_ACL_LEN_ONLY is set, we call nfs4_write_cached_acl with the
second argument set to NULL. This results in only the acl length being
cached.


> > diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> > index 18fae29..a88fcd0 100644
> > --- a/fs/nfs/nfs4xdr.c
> > +++ b/fs/nfs/nfs4xdr.c
> > @@ -5101,7 +5101,7 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
> >  		hdrlen = (u8 *)xdr->p - (u8 *)iov->iov_base;
> >  		attrlen += res->acl_data_offset;
> >  		if (attrlen > page_len) {
> > -			if (res->acl_flags & NFS4_ACL_LEN_REQUEST) {
> > +			if (res->acl_flags & NFS4_ACL_LEN_ONLY) {
> 
> The logic here still looks incorrect. If the user is only requesting the
> acl length, then we shouldn't care about the 'attrlen > page_len' test.

This is a result of a feature introduced with an earlier
patch(bf118a342f10dafe44b14451a1392c3254629a1f) and the behaviour is
described in the comment above __nfs4_get_acl_uncached().

***
The getxattr API returns the required buffer length when called with a
NULL buf. The NFSv4 acl tool then calls getxattr again after allocating
the required buf.  On a NULL buf, we send a page of data to the server
guessing that the ACL request can be serviced by a page. If so, we cache
up to the page of ACL data, and the 2nd call to getxattr is serviced by
the cache. If not so, we throw away the page, and cache the required
length. The next getxattr call will then produce another round trip to
the server, this time with the input buf of the required size.
***

Check to see if the ACL attribute length returned by the server is
larger than the buffer allocated for it.
if (attrlen > page_len) {
	If the length returned is smaller than buffer allocated. 
	Check flags to see if the user had only requested for length.
	if (res->acl_flags & NFS4_ACL_LEN_ONLY) {
		/* getxattr interface called with a NULL buf */
		If yes, just save length and return
		res->acl_len = attrlen;
		goto out;
	}
	Else return -EINVAL.
	dprintk("NFS: acl reply: attrlen %u > page_len %zu\n",
		attrlen, page_len);
	return -EINVAL;
}
At the end of this if condition, we have determined that the buffer
length we allocated is large enough for the length of ACL returned.
So clear NFS4_ACL_LEN_ONLY if set.
/* At this stage we have the complete ACL */
res->acl_flags &= ~NFS4_ACL_LEN_ONLY;


> There also appears to remain a lot of illegal deferencing of xdr->p even
> after this patch. We should be able to fix that by replacing
> xdr_read_pages with a call to xdr_enter_page() before we call
> decode_attr_bitmap()...


Sachin Prabhu

