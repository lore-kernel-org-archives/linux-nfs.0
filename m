Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f182.google.com ([209.85.192.182]:61772 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400AbaHJMqx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Aug 2014 08:46:53 -0400
Message-ID: <53E769A7.4010303@gmail.com>
Date: Sun, 10 Aug 2014 20:46:31 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Jeff Layton <jeff.layton@primarydata.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>, jlayton@redhat.com,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 1/3] NFSD: New FL_NFSD for marking file_lock belongs to
 NFSD
References: <53BAAAC5.9000106@gmail.com>	<53E22EA5.70708@gmail.com> <20140809065112.700e0ecc@tlielax.poochiereds.net>
In-Reply-To: <20140809065112.700e0ecc@tlielax.poochiereds.net>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 8/9/2014 18:51, Jeff Layton wrote:
> On Wed, 06 Aug 2014 21:33:25 +0800
> Kinglong Mee <kinglongmee@gmail.com> wrote:
> 
>> Using fl_flags instead of fl_lmops for marking file_lock belongs to NFSD.
>>
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  fs/nfsd/nfs4state.c | 15 ++++-----------
>>  include/linux/fs.h  |  1 +
>>  2 files changed, 5 insertions(+), 11 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 2e80a59..24168ae 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -4867,17 +4867,12 @@ nfs4_transform_lock_offset(struct file_lock *lock)
>>  		lock->fl_end = OFFSET_MAX;
>>  }
>>  
>> -/* Hack!: For now, we're defining this just so we can use a pointer to it
>> - * as a unique cookie to identify our (NFSv4's) posix locks. */
>> -static const struct lock_manager_operations nfsd_posix_mng_ops  = {
>> -};
>> -
>>  static inline void
>>  nfs4_set_lock_denied(struct file_lock *fl, struct nfsd4_lock_denied *deny)
>>  {
>>  	struct nfs4_lockowner *lo;
>>  
>> -	if (fl->fl_lmops == &nfsd_posix_mng_ops) {
>> +	if (fl->fl_flags & FL_NFSD) {
>>  		lo = (struct nfs4_lockowner *) fl->fl_owner;
>>  		deny->ld_owner.data = kmemdup(lo->lo_owner.so_owner.data,
>>  					lo->lo_owner.so_owner.len, GFP_KERNEL);
>> @@ -5241,8 +5236,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>>  	file_lock->fl_owner = (fl_owner_t)lock_sop;
>>  	file_lock->fl_pid = current->tgid;
>>  	file_lock->fl_file = filp;
>> -	file_lock->fl_flags = FL_POSIX;
>> -	file_lock->fl_lmops = &nfsd_posix_mng_ops;
>> +	file_lock->fl_flags = FL_POSIX | FL_NFSD;
>>  	file_lock->fl_start = lock->lk_offset;
>>  	file_lock->fl_end = last_byte_offset(lock->lk_offset, lock->lk_length);
>>  	nfs4_transform_lock_offset(file_lock);
>> @@ -5375,7 +5369,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>>  	if (lo)
>>  		file_lock->fl_owner = (fl_owner_t)lo;
>>  	file_lock->fl_pid = current->tgid;
>> -	file_lock->fl_flags = FL_POSIX;
>> +	file_lock->fl_flags = FL_POSIX | FL_NFSD;
>>  
>>  	file_lock->fl_start = lockt->lt_offset;
>>  	file_lock->fl_end = last_byte_offset(lockt->lt_offset, lockt->lt_length);
>> @@ -5437,8 +5431,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>>  	file_lock->fl_owner = (fl_owner_t)lockowner(stp->st_stateowner);
>>  	file_lock->fl_pid = current->tgid;
>>  	file_lock->fl_file = filp;
>> -	file_lock->fl_flags = FL_POSIX;
>> -	file_lock->fl_lmops = &nfsd_posix_mng_ops;
>> +	file_lock->fl_flags = FL_POSIX | FL_NFSD;
>>  	file_lock->fl_start = locku->lu_offset;
>>  
>>  	file_lock->fl_end = last_byte_offset(locku->lu_offset,
>> diff --git a/include/linux/fs.h b/include/linux/fs.h
>> index e11d60c..4d40097 100644
>> --- a/include/linux/fs.h
>> +++ b/include/linux/fs.h
>> @@ -819,6 +819,7 @@ static inline struct file *get_file(struct file *f)
>>  #define FL_DOWNGRADE_PENDING	256 /* Lease is being downgraded */
>>  #define FL_UNLOCK_PENDING	512 /* Lease is being broken */
>>  #define FL_OFDLCK	1024	/* lock is "owned" by struct file */
>> +#define FL_NFSD		2048	/* NFSD holds this lock */
>>  
>>  /*
>>   * Special return value from posix_lock_file() and vfs_lock_file() for
> 
> Honestly, I'd prefer not using a fl_flag for this. Why, might you ask?
> 
> Currently, there are two alternate lock managers in the kernel (nfsd
> and lockd) but there could (in principle) be an arbitrary number of
> them later. What's so special about knfsd that it warrants its own flag?
> 
> I think existing use of an empty lock_manager_operations is a cleaner
> solution than this for identifying locks owned by knfsd.

Thanks for your explication.
I will drop this patch in v2.

thanks,
Kinglong Mee
