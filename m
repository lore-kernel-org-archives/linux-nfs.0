Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CDF5C433B4
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Apr 2021 19:55:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id D72A160241
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Apr 2021 19:55:22 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S238012AbhDSTzw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 19 Apr 2021 15:55:52 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:33874 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S235788AbhDSTzv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Apr 2021 15:55:51 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id E2AC8C06174A
        for <linux-nfs@vger.kernel.org>; Mon, 19 Apr 2021 12:55:21 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 85196727D; Mon, 19 Apr 2021 15:55:21 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 85196727D
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1618862121;
        bh=PpmGAG09Yg+EUPgWmMG89WB800W28T3p0pCdeEOkmYA=;
        h=Date:To:Cc:Subject:References:In-Reply-To:From:From;
        b=lkKJFKyXLq12EezfR35Ey7y+I7onrMO3i5o9bbUvWr2JOLi+7HmyZxVVtmDUo+sOY
         R8NuHjS6KS0BG4GFZlRkPW6mR8E4USREuYcrGCrh9Yj4XDkJh1G2RAvKZb1RTxUKzv
         mQYhjXlJPTjRqMyNmsUJGnI96VHM/7lkUcujaPGk=
Date:   Mon, 19 Apr 2021 15:55:21 -0400
To:     Chuck Lever III <chuck.lever@oracle.com>
Cc:     Bruce Fields <bfields@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/5] nfsd: ensure new clients break delegations
Message-ID: <20210419195521.GB17661@fieldses.org>
References: <1618596018-9899-1-git-send-email-bfields@redhat.com>
 <742D63C9-53E9-45B2-9604-C8DBB42EC810@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <742D63C9-53E9-45B2-9604-C8DBB42EC810@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Apr 16, 2021 at 07:11:36PM +0000, Chuck Lever III wrote:
> 
> 
> > On Apr 16, 2021, at 2:00 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> > 
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > If nfsd already has an open file that it plans to use for IO from
> > another,
> 
> from another... client?

Yes, thanks.--b.

> 
> 
> > it may not need to do another vfs open, but it still may need
> > to break any delegations in case the existing opens are for another
> > client.
> > 
> > Symptoms are that we may incorrectly fail to break a delegation on a
> > write open from a different client, when the delegation-holding client
> > already has a write open.
> > 
> > Fixes: 28df3d1539de ("nfsd: clients don't need to break their own delegations")
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> > fs/nfsd/nfs4state.c | 24 +++++++++++++++++++-----
> > 1 file changed, 19 insertions(+), 5 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 97447a64bad0..886e50ed07c2 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -4869,6 +4869,11 @@ static __be32 nfs4_get_vfs_file(struct svc_rqst *rqstp, struct nfs4_file *fp,
> > 	if (nf)
> > 		nfsd_file_put(nf);
> > 
> > +	status = nfserrno(nfsd_open_break_lease(cur_fh->fh_dentry->d_inode,
> > +								access));
> > +	if (status)
> > +		goto out_put_access;
> > +
> > 	status = nfsd4_truncate(rqstp, cur_fh, open);
> > 	if (status)
> > 		goto out_put_access;
> > @@ -6849,11 +6854,20 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> > static __be32 nfsd_test_lock(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file_lock *lock)
> > {
> > 	struct nfsd_file *nf;
> > -	__be32 err = nfsd_file_acquire(rqstp, fhp, NFSD_MAY_READ, &nf);
> > -	if (!err) {
> > -		err = nfserrno(vfs_test_lock(nf->nf_file, lock));
> > -		nfsd_file_put(nf);
> > -	}
> > +	__be32 err;
> > +
> > +	err = nfsd_file_acquire(rqstp, fhp, NFSD_MAY_READ, &nf);
> > +	if (err)
> > +		return err;
> > +	fh_lock(fhp); /* to block new leases till after test_lock: */
> > +	err = nfserrno(nfsd_open_break_lease(fhp->fh_dentry->d_inode,
> > +							NFSD_MAY_READ));
> > +	if (err)
> > +		goto out;
> > +	err = nfserrno(vfs_test_lock(nf->nf_file, lock));
> > +out:
> > +	fh_unlock(fhp);
> > +	nfsd_file_put(nf);
> > 	return err;
> > }
> > 
> > -- 
> > 2.30.2
> > 
> 
> --
> Chuck Lever
> 
> 
