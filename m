From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH v2 11/47] nfsd41: sessionid hashing
Date: Mon, 30 Mar 2009 23:34:32 +0300
Message-ID: <49D12CD8.7060807@panasas.com>
References: <49CDDFC2.4070402@panasas.com> <1238229110-10339-1-git-send-email-bhalevy@panasas.com> <20090330200812.GI31237@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:7623 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758251AbZC3Ueh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2009 16:34:37 -0400
In-Reply-To: <20090330200812.GI31237@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar. 30, 2009, 23:08 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Sat, Mar 28, 2009 at 11:31:50AM +0300, Benny Halevy wrote:
>> From: Marc Eshel <eshel@almaden.ibm.com>
>>
>> Simple sessionid hashing using its monotonically increasing sequence number.
>>
>> Locking considerations:
>> sessionid_hashtbl access is controlled by the sessionid_lock spin lock.
>> It must be taken for insert, delete, and lookup.
>> nfsd4_sequence looks up the session id and if the session is found,
>> it calls nfsd4_get_session (still under the sessionid_lock).
>> nfsd4_destroy_session calls nfsd4_put_session after unhashing
>> it, so when the session's kref reaches zero it's going to get freed.
>>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> [we don't use a prime for sessionid hash table size]
>> [use sessionid_lock spin lock]
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfsd/nfs4state.c        |   57 +++++++++++++++++++++++++++++++++++++++++++-
>>  include/linux/nfsd/state.h |    7 +++++
>>  2 files changed, 63 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index df9d42e..ac4e8f2 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -383,11 +383,62 @@ static void release_openowner(struct nfs4_stateowner *sop)
>>  }
>>  
>>  #if defined(CONFIG_NFSD_V4_1)
>> +static DEFINE_SPINLOCK(sessionid_lock);
>> +#define SESSION_HASH_SIZE	512
>> +static struct list_head sessionid_hashtbl[SESSION_HASH_SIZE];
>> +
>> +static inline int
>> +hash_sessionid(struct nfs4_sessionid *sessionid)
>> +{
>> +	struct nfsd4_sessionid *sid = (struct nfsd4_sessionid *)sessionid;
>> +
>> +	return sid->sequence % SESSION_HASH_SIZE;
>> +}
>> +
>> +static inline void
>> +dump_sessionid(const char *fn, struct nfs4_sessionid *sessionid)
>> +{
>> +	u32 *ptr = (u32 *)(&sessionid->data[0]);
>> +	dprintk("%s: %u:%u:%u:%u\n", fn, ptr[0], ptr[1], ptr[2], ptr[3]);
>> +}
>> +
>> +/* caller must hold sessionid_lock */
>> +static struct nfsd4_session *
>> +find_in_sessionid_hashtbl(struct nfs4_sessionid *sessionid)
>> +{
>> +	struct nfsd4_session *elem;
>> +	int idx;
>> +
>> +	dump_sessionid(__func__, sessionid);
>> +	idx = hash_sessionid(sessionid);
>> +	dprintk("%s: idx is %d\n", __func__, idx);
>> +	/* Search in the appropriate list */
>> +	list_for_each_entry(elem, &sessionid_hashtbl[idx], se_hash) {
>> +		dump_sessionid("list traversal", &elem->se_sessionid);
>> +		if (!memcmp(elem->se_sessionid.data, sessionid->data,
>> +			    NFS4_MAX_SESSIONID_LEN)) {
>> +			return elem;
>> +		}
>> +	}
>> +
>> +	dprintk("%s: session not found\n", __func__);
> 
> Massive dprintk overkill in this function.

Yeah, I agree we can get rid of them by now.

> 
>> +	return NULL;
>> +}
>> +
>> +/* caller must hold sessionid_lock */
>>  static void
>> -release_session(struct nfsd4_session *ses)
>> +unhash_session(struct nfsd4_session *ses)
>>  {
>>  	list_del(&ses->se_hash);
>>  	list_del(&ses->se_perclnt);
>> +}
>> +
>> +static void
>> +release_session(struct nfsd4_session *ses)
>> +{
>> +	spin_lock(&sessionid_lock);
>> +	unhash_session(ses);
>> +	spin_unlock(&sessionid_lock);
>>  	nfsd4_put_session(ses);
>>  }
> 
> It's not obvious from the names what the difference between
> release_session() and nfsd4_put_session() is.
> 
> How about just renaming release_session() to unhash_session(), and
> dumping hash_session?  The two list_del()'s don't need their own
> function.

We call unhash_session on its own later on from destroy_session,
then we destroy the callback client and finally put the session.

We can embed release_session into expire_client since it's
its only use though expire_client is hairy enough I'm not
sure we want to add more stuff into it.  If we're going
this direction, I'd consider refactoring it and taking
the many loops it's doing out into their own functions.
(we'll add a couple more for pNFS - for releasing layouts
and layoutrecalls)

Benny

> 
> --b.
> 
>>  
>> @@ -3213,6 +3264,10 @@ nfs4_state_init(void)
>>  		INIT_LIST_HEAD(&unconf_str_hashtbl[i]);
>>  		INIT_LIST_HEAD(&unconf_id_hashtbl[i]);
>>  	}
>> +#if defined(CONFIG_NFSD_V4_1)
>> +	for (i = 0; i < SESSION_HASH_SIZE; i++)
>> +		INIT_LIST_HEAD(&sessionid_hashtbl[i]);
>> +#endif /* CONFIG_NFSD_V4_1 */
>>  	for (i = 0; i < FILE_HASH_SIZE; i++) {
>>  		INIT_LIST_HEAD(&file_hashtbl[i]);
>>  	}
>> diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
>> index 29624b4..7592d7b 100644
>> --- a/include/linux/nfsd/state.h
>> +++ b/include/linux/nfsd/state.h
>> @@ -133,6 +133,13 @@ nfsd4_get_session(struct nfsd4_session *ses)
>>  	kref_get(&ses->se_ref);
>>  }
>>  
>> +/* formatted contents of nfs4_sessionid */
>> +struct nfsd4_sessionid {
>> +	clientid_t	clientid;
>> +	u32		sequence;
>> +	u32		reserved;
>> +};
>> +
>>  #define HEXDIR_LEN     33 /* hex version of 16 byte md5 of cl_name plus '\0' */
>>  
>>  /*
>> -- 
>> 1.6.2.1
>>
