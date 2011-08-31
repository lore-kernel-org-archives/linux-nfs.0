Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:56310 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755220Ab1HaU2M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Aug 2011 16:28:12 -0400
Received: by gxk21 with SMTP id 21so887436gxk.19
        for <linux-nfs@vger.kernel.org>; Wed, 31 Aug 2011 13:28:12 -0700 (PDT)
Message-ID: <4E5E994E.6040107@tonian.com>
Date: Wed, 31 Aug 2011 13:27:58 -0700
From: Benny Halevy <bhalevy@tonian.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org, Casey Bodley <cbodley@citi.umich.edu>
Subject: Re: [PATCH] nfsd4: in-stateid seqid should start with 1
References: <20110831195329.GD19223@fieldses.org>
In-Reply-To: <20110831195329.GD19223@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Don't we also need the following?

As per RFC5661, skip zero seqid when wrapping around
while updating a stateid.

Signed-off-by: Benny Halevy <bhalevy@tonian.com>

git diff --stat -p -M
 fs/nfsd/state.h |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 77f98b8..7d18d3e 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -289,7 +289,10 @@ struct nfs4_client_reclaim {
 static inline void
 update_stateid(stateid_t *stateid)
 {
-	stateid->si_generation++;
+	u32 new = stateid->si_generation + 1;
+	if (new == 0)
+		new = 1;
+	stateid->si_generation = new;
 }

 /* A reasonable value for REPLAY_ISIZE was estimated as follows:

On 2011-08-31 12:53, J. Bruce Fields wrote:
> From: J. Bruce Fields <bfields@redhat.com>
> 
> Thanks to Casey for reminding me that 5661 gives a special meaning to a
> value of 0 in the stateid's seqid field, so we should instead be
> starting out stateid's with si_generation 1.
> 
> Reported-by: Casey Bodley <cbodley@citi.umich.edu>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfsd/nfs4state.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 49c3dd1..7caa812 100644
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
> @@ -2303,7 +2303,7 @@ init_stateid(struct nfs4_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *
>  	stp->st_stateid.si_boot = boot_time;
>  	stp->st_stateid.si_stateownerid = oo->oo_owner.so_id;
>  	stp->st_stateid.si_fileid = fp->fi_id;
> -	stp->st_stateid.si_generation = 0;
> +	stp->st_stateid.si_generation = 1;
>  	stp->st_access_bmap = 0;
>  	stp->st_deny_bmap = 0;
>  	__set_bit(open->op_share_access & ~NFS4_SHARE_WANT_MASK,
> @@ -3898,7 +3898,7 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
>  	stp->st_stateid.si_boot = boot_time;
>  	stp->st_stateid.si_stateownerid = lo->lo_owner.so_id;
>  	stp->st_stateid.si_fileid = fp->fi_id;
> -	stp->st_stateid.si_generation = 0;
> +	stp->st_stateid.si_generation = 1;
>  	stp->st_access_bmap = 0;
>  	stp->st_deny_bmap = open_stp->st_deny_bmap;
>  	stp->st_openstp = open_stp;
