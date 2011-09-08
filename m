From: Benny Halevy <bhalevy@tonian.com>
Subject: Re: [PATCH] nfsd4: in-stateid seqid should start with 1
Date: Thu, 08 Sep 2011 08:32:24 -0400
Message-ID: <4E68B5D8.9080703@tonian.com>
References: <20110831195329.GD19223@fieldses.org> <4E5E994E.6040107@tonian.com> <20110831211959.GG19223@fieldses.org> <4E5EA7B2.5010500@tonian.com> <20110831213314.GH19223@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, Casey Bodley <cbodley@citi.umich.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:62146 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932400Ab1IHMco (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Sep 2011 08:32:44 -0400
Received: by qyk34 with SMTP id 34so393563qyk.19
        for <linux-nfs@vger.kernel.org>; Thu, 08 Sep 2011 05:32:43 -0700 (PDT)
In-Reply-To: <20110831213314.GH19223@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-08-31 17:33, J. Bruce Fields wrote:
> On Wed, Aug 31, 2011 at 02:29:22PM -0700, Benny Halevy wrote:
>> On 2011-08-31 14:19, J. Bruce Fields wrote:
>>> On Wed, Aug 31, 2011 at 01:27:58PM -0700, Benny Halevy wrote:
>>>> Don't we also need the following?
>>>>
>>>> As per RFC5661, skip zero seqid when wrapping around
>>>> while updating a stateid.
>>>
>>> Yep, done:
>>>
>>> 	http://marc.info/?l=linux-nfs&m=131439774426154&w=2
>>
>> yup, thanks!
>>
>>>
>>> I need to send out my patches one at a time rather than fifteen at once
>>> if I want people to read them....
>>
>> My bad :-)
> 
> I'm gonna start inserting little "respond here if you read this far"
> comments.
> 
> And actually I didn't read Casey's report carefully: he was just
> complaining about delegation stateid's.  I don't think they matter much,
> as their seqid field never changes, but may as well use the same as the
> others.  And while we're there, make this uniform for v4.0 as well.

Ack :)

> 
> --b.
> 
> commit 80809fa40f8cfb3cf0bf006e3218bbd00584b38d
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Wed Aug 31 15:47:21 2011 -0400
> 
>     nfsd4: make delegation stateid's seqid start at 1
>     
>     Thanks to Casey for reminding me that 5661 gives a special meaning to a
>     value of 0 in the stateid's seqid field, so all stateid's should start
>     out with si_generation 1.  We were doing that in the open and lock
>     cases for minorversion 1, but not for the delegation stateid, and not
>     for openstateid's with v4.0.
>     
>     It doesn't *really* matter much for v4.0 or for delegation stateid's
>     (which never get the seqid field incremented), but we may as well do the
>     same for all of them.
>     
>     Reported-by: Casey Bodley <cbodley@citi.umich.edu>
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 49c3dd1..dc83ca1 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -251,7 +251,7 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_stateid *stp, struct svc_f
>  	dp->dl_stateid.si_boot = boot_time;
>  	dp->dl_stateid.si_stateownerid = current_delegid++;
>  	dp->dl_stateid.si_fileid = 0;
> -	dp->dl_stateid.si_generation = 0;
> +	dp->dl_stateid.si_generation = 1;
>  	fh_copy_shallow(&dp->dl_fh, &current_fh->fh_handle);
>  	dp->dl_time = 0;
>  	atomic_set(&dp->dl_count, 1);
> @@ -2303,6 +2303,7 @@ init_stateid(struct nfs4_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *
>  	stp->st_stateid.si_boot = boot_time;
>  	stp->st_stateid.si_stateownerid = oo->oo_owner.so_id;
>  	stp->st_stateid.si_fileid = fp->fi_id;
> +	/* note will be incremented before first return to client: */
>  	stp->st_stateid.si_generation = 0;
>  	stp->st_access_bmap = 0;
>  	stp->st_deny_bmap = 0;
> @@ -2893,7 +2894,6 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
>  		status = nfs4_upgrade_open(rqstp, fp, current_fh, stp, open);
>  		if (status)
>  			goto out;
> -		update_stateid(&stp->st_stateid);
>  	} else {
>  		status = nfs4_new_open(rqstp, &stp, fp, current_fh, open);
>  		if (status)
> @@ -2904,9 +2904,8 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
>  			release_open_stateid(stp);
>  			goto out;
>  		}
> -		if (nfsd4_has_session(&resp->cstate))
> -			update_stateid(&stp->st_stateid);
>  	}
> +	update_stateid(&stp->st_stateid);
>  	memcpy(&open->op_stateid, &stp->st_stateid, sizeof(stateid_t));
>  
>  	if (nfsd4_has_session(&resp->cstate))
> @@ -3898,6 +3897,7 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
>  	stp->st_stateid.si_boot = boot_time;
>  	stp->st_stateid.si_stateownerid = lo->lo_owner.so_id;
>  	stp->st_stateid.si_fileid = fp->fi_id;
> +	/* note will be incremented before first return to client: */
>  	stp->st_stateid.si_generation = 0;
>  	stp->st_access_bmap = 0;
>  	stp->st_deny_bmap = open_stp->st_deny_bmap;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
