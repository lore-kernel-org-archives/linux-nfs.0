Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:42118 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755636AbcGHVx0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jul 2016 17:53:26 -0400
Subject: Re: [PATCH] nfsd: Make creates return EEXIST correctly instead of EPERM
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <20160708205413.GC11269@fieldses.org>
Date: Fri, 8 Jul 2016 17:53:19 -0400
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Message-Id: <DFD42803-99B2-4844-AAD3-0707E0F7DC66@linuxhacker.ru>
References: <1467942466-3081422-1-git-send-email-green@linuxhacker.ru> <20160708205413.GC11269@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 8, 2016, at 4:54 PM, J. Bruce Fields wrote:

> On Thu, Jul 07, 2016 at 09:47:46PM -0400, Oleg Drokin wrote:
>> It looks like we are bit overzealous about failing mkdir/create/mknod
>> with permission denied if the parent dir is not writeable.
>> Need to make sure the name does not exist first, because we need to
>> return EEXIST in that case.
>> 
>> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
>> ---
>> A very similar problem exists with symlinks, but the patch is more
>> involved, so assuming this one is ok, I'll send a symlink one separately.
>> fs/nfsd/nfs4proc.c |  6 +++++-
>> fs/nfsd/vfs.c      | 11 ++++++++++-
>> 2 files changed, 15 insertions(+), 2 deletions(-)
>> 
>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> index de1ff1d..0067520 100644
>> --- a/fs/nfsd/nfs4proc.c
>> +++ b/fs/nfsd/nfs4proc.c
>> @@ -605,8 +605,12 @@ nfsd4_create(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>> 
>> 	fh_init(&resfh, NFS4_FHSIZE);
>> 
>> +	/*
>> +	 * We just check thta parent is accessible here, nfsd_* do their
>> +	 * own access permission checks
>> +	 */
>> 	status = fh_verify(rqstp, &cstate->current_fh, S_IFDIR,
>> -			   NFSD_MAY_CREATE);
>> +			   NFSD_MAY_EXEC);
>> 	if (status)
>> 		return status;
>> 
>> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
>> index 6fbd81e..6a45ec6 100644
>> --- a/fs/nfsd/vfs.c
>> +++ b/fs/nfsd/vfs.c
>> @@ -1161,7 +1161,11 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
>> 	if (isdotent(fname, flen))
>> 		goto out;
>> 
>> -	err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
>> +	/*
>> +	 * Even though it is a create, first we see if we are even allowed
>> +	 * to peek inside the parent
>> +	 */
>> +	err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_EXEC);
> 
> Looks like in the v3 case we haven't actually locked the directory yet
> at this point so this check is a little race-prone.

In reality this check is not really needed, I suspect.
When we call vfs_create/mknod/mkdir later on, it has it's own permission check
anyway so if there was a race and somebody changed dir access in the middle,
there's going to be another check anyway and it would be caught.
Unless there's some weird server-side permission wiggling as well that makes it
ineffective, but I imagine that one cannot really change in a racy way?

> I wonder why the code's structured that way--it's confusing.

Probably years of accumulated "damage" ;)

> --b.
> 
>> 	if (err)
>> 		goto out;
>> 
>> @@ -1211,6 +1215,11 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
>> 		goto out; 
>> 	}
>> 
>> +	/* Now let's see if we actually have permissions to create */
>> +	err = nfsd_permission(rqstp, fhp->fh_export, dentry, NFSD_MAY_CREATE);
>> +	if (err)
>> +		goto out;
>> +
>> 	if (!(iap->ia_valid & ATTR_MODE))
>> 		iap->ia_mode = 0;
>> 	iap->ia_mode = (iap->ia_mode & S_IALLUGO) | type;
>> -- 
>> 2.7.4

