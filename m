Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:34688 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751638AbbHUCSq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2015 22:18:46 -0400
Received: by igui7 with SMTP id i7so8309084igu.1
        for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2015 19:18:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAKVebiVBceP97rhy6ZMv9zOP5oMkKxzcV=OYscp1XvNkvuVJVQ@mail.gmail.com>
References: <1440069440-27454-1-git-send-email-jeff.layton@primarydata.com>
 <1440069440-27454-16-git-send-email-jeff.layton@primarydata.com> <CAKVebiVBceP97rhy6ZMv9zOP5oMkKxzcV=OYscp1XvNkvuVJVQ@mail.gmail.com>
From: Peng Tao <bergwolf@primarydata.com>
Date: Thu, 20 Aug 2015 19:18:25 -0700
Message-ID: <CAKVebiUnKdkv9U24Xb-YaXpRuONXCULh7HBD89E3Cr4mxKgZvg@mail.gmail.com>
Subject: Re: [PATCH v3 15/20] nfsd: call flush_delayed_fput from nfsd_file_close_fh
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>, Kinglong Mee <kinglongmee@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 20, 2015 at 6:01 PM, Peng Tao <bergwolf@primarydata.com> wrote:
> On Thu, Aug 20, 2015 at 4:17 AM, Jeff Layton <jlayton@poochiereds.net> wrote:
>> ...when there are open files to be closed.
>>
>> When knfsd does an fput(), it gets queued to a list and a workqueue job
>> is then scheduled to do the actual __fput work. In the case of knfsd
>> closing down the file prior to a REMOVE or RENAME, we really want to
>> ensure that those files are closed prior to returning. When there are
>> files to be closed, call flush_delayed_fput to ensure this.
>>
>> There are deadlock possibilities if you call flush_delayed_fput while
>> holding locks, however. In the case of nfsd_rename, we don't even do the
>> lookups of the dentries to be renamed until we've locked for rename.
>>
>> Once we've figured out what the target dentry is for a rename, check to
>> see whether there are cached open files associated with it. If there
>> are, then unwind all of the locking, close them all, and then reattempt
>> the rename.
>>
>> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
>> ---
>>  fs/file_table.c     |  1 +
>>  fs/nfsd/filecache.c | 33 ++++++++++++++++++++++++++++++++-
>>  fs/nfsd/filecache.h |  1 +
>>  fs/nfsd/trace.h     | 10 +++++++++-
>>  fs/nfsd/vfs.c       | 47 +++++++++++++++++++++++++++++++++++++++--------
>>  5 files changed, 82 insertions(+), 10 deletions(-)
>>
>> diff --git a/fs/file_table.c b/fs/file_table.c
>> index 7f9d407c7595..33898e72618c 100644
>> --- a/fs/file_table.c
>> +++ b/fs/file_table.c
>> @@ -257,6 +257,7 @@ void flush_delayed_fput(void)
>>  {
>>         delayed_fput(NULL);
>>  }
>> +EXPORT_SYMBOL_GPL(flush_delayed_fput);
>>
>>  static DECLARE_DELAYED_WORK(delayed_fput_work, delayed_fput);
>>
>> diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
>> index 4bd683f03b6e..b62942ba6e7b 100644
>> --- a/fs/nfsd/filecache.c
>> +++ b/fs/nfsd/filecache.c
>> @@ -284,6 +284,34 @@ nfsd_file_find_locked(struct inode *inode, unsigned int may_flags,
>>  }
>>
>>  /**
>> + * nfsd_file_is_cached - are there any cached open files for this fh?
>> + * @inode: inode of the file to check
>> + *
>> + * Scan the hashtable for open files that match this fh. Returns true if there
>> + * are any, and false if not.
>> + */
>> +bool
>> +nfsd_file_is_cached(struct inode *inode)
>> +{
>> +       bool                    ret = false;
>> +       struct nfsd_file        *nf;
>> +       unsigned int            hashval = (unsigned int)hash_ptr(inode, NFSD_FILE_HASH_BITS);
>> +
>> +       rcu_read_lock();
>> +       hlist_for_each_entry_rcu(nf, &nfsd_file_hashtbl[hashval].nfb_head,
>> +                                nf_node) {
>> +               if (inode == nf->nf_inode) {
>> +                       ret = true;
>> +                       break;
>> +               }
>> +       }
>> +       rcu_read_unlock();
>> +       trace_nfsd_file_is_cached(hashval, inode, (int)ret);
>> +       return ret;
>> +}
>> +
>> +
>> +/**
>>   * nfsd_file_close_inode - attempt to forcibly close a nfsd_file
>>   * @inode: inode of the file to attempt to remove
>>   *
>> @@ -305,7 +333,10 @@ nfsd_file_close_inode(struct inode *inode)
>>         }
>>         spin_unlock(&nfsd_file_hashtbl[hashval].nfb_lock);
>>         trace_nfsd_file_close_inode(hashval, inode, !list_empty(&dispose));
>> -       nfsd_file_dispose_list(&dispose);
>> +       if (!list_empty(&dispose)) {
>> +               nfsd_file_dispose_list(&dispose);
>> +               flush_delayed_fput();
> It looks like flush_delayed_fput() is not exported symbol?
>
> And if flush_delayed_fput() is acceptable, it looks like __fput_sync()
> is a better fit, because knfsd would not try to do all the delayed
> fput() work, just the dispose list...
oh, just saw that flush_delayed_fput() is exported in this patch!
sorry for the noise. But I still think __fput_sync() might be a better
fit, despite the assertion there... I'm fine with settling with
flush_delayed_fput() though since calling __fput_sync() from a kernel
thread might get more objections.

Cheers,
Tao

>
> Cheers,
> Tao
>
>> +       }
>>  }
>>
>>  __be32
>> diff --git a/fs/nfsd/filecache.h b/fs/nfsd/filecache.h
>> index 191cdb25aa66..4a873efb7953 100644
>> --- a/fs/nfsd/filecache.h
>> +++ b/fs/nfsd/filecache.h
>> @@ -27,6 +27,7 @@ void nfsd_file_cache_shutdown(void);
>>  void nfsd_file_put(struct nfsd_file *nf);
>>  struct nfsd_file *nfsd_file_get(struct nfsd_file *nf);
>>  void nfsd_file_close_inode(struct inode *inode);
>> +bool nfsd_file_is_cached(struct inode *inode);
>>  __be32 nfsd_file_acquire(struct svc_rqst *rqstp, struct svc_fh *fhp,
>>                   unsigned int may_flags, struct nfsd_file **nfp);
>>  #endif /* _FS_NFSD_FILECACHE_H */
>> diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
>> index 95af3b9c7b66..fc6d8ee51a00 100644
>> --- a/fs/nfsd/trace.h
>> +++ b/fs/nfsd/trace.h
>> @@ -140,7 +140,7 @@ TRACE_EVENT(nfsd_file_acquire,
>>                         be32_to_cpu(__entry->status))
>>  );
>>
>> -TRACE_EVENT(nfsd_file_close_inode,
>> +DECLARE_EVENT_CLASS(nfsd_file_search_class,
>>         TP_PROTO(unsigned int hash, struct inode *inode, int found),
>>         TP_ARGS(hash, inode, found),
>>         TP_STRUCT__entry(
>> @@ -156,6 +156,14 @@ TRACE_EVENT(nfsd_file_close_inode,
>>         TP_printk("hash=0x%x inode=0x%p found=%d", __entry->hash,
>>                         __entry->inode, __entry->found)
>>  );
>> +
>> +#define DEFINE_NFSD_FILE_SEARCH_EVENT(name)                            \
>> +DEFINE_EVENT(nfsd_file_search_class, name,                             \
>> +       TP_PROTO(unsigned int hash, struct inode *inode, int found),    \
>> +       TP_ARGS(hash, inode, found))
>> +
>> +DEFINE_NFSD_FILE_SEARCH_EVENT(nfsd_file_close_inode);
>> +DEFINE_NFSD_FILE_SEARCH_EVENT(nfsd_file_is_cached);
>>  #endif /* _NFSD_TRACE_H */
>>
>>  #undef TRACE_INCLUDE_PATH
>> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
>> index 98d3b9d96480..4cc78a4ec694 100644
>> --- a/fs/nfsd/vfs.c
>> +++ b/fs/nfsd/vfs.c
>> @@ -1592,6 +1592,17 @@ nfsd_close_cached_files(struct dentry *dentry)
>>                 nfsd_file_close_inode(inode);
>>  }
>>
>> +static bool
>> +nfsd_has_cached_files(struct dentry *dentry)
>> +{
>> +       bool            ret = false;
>> +       struct inode *inode = d_inode(dentry);
>> +
>> +       if (inode && S_ISREG(inode->i_mode))
>> +               ret = nfsd_file_is_cached(inode);
>> +       return ret;
>> +}
>> +
>>  /*
>>   * Rename a file
>>   * N.B. After this call _both_ ffhp and tfhp need an fh_put
>> @@ -1604,6 +1615,7 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
>>         struct inode    *fdir, *tdir;
>>         __be32          err;
>>         int             host_err;
>> +       bool            has_cached = false;
>>
>>         err = fh_verify(rqstp, ffhp, S_IFDIR, NFSD_MAY_REMOVE);
>>         if (err)
>> @@ -1622,6 +1634,7 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
>>         if (!flen || isdotent(fname, flen) || !tlen || isdotent(tname, tlen))
>>                 goto out;
>>
>> +retry:
>>         host_err = fh_want_write(ffhp);
>>         if (host_err) {
>>                 err = nfserrno(host_err);
>> @@ -1661,12 +1674,16 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
>>         if (ffhp->fh_export->ex_path.dentry != tfhp->fh_export->ex_path.dentry)
>>                 goto out_dput_new;
>>
>> -       nfsd_close_cached_files(ndentry);
>> -       host_err = vfs_rename(fdir, odentry, tdir, ndentry, NULL, 0);
>> -       if (!host_err) {
>> -               host_err = commit_metadata(tfhp);
>> -               if (!host_err)
>> -                       host_err = commit_metadata(ffhp);
>> +       if (nfsd_has_cached_files(ndentry)) {
>> +               has_cached = true;
>> +               goto out_dput_old;
>> +       } else {
>> +               host_err = vfs_rename(fdir, odentry, tdir, ndentry, NULL, 0);
>> +               if (!host_err) {
>> +                       host_err = commit_metadata(tfhp);
>> +                       if (!host_err)
>> +                               host_err = commit_metadata(ffhp);
>> +               }
>>         }
>>   out_dput_new:
>>         dput(ndentry);
>> @@ -1679,12 +1696,26 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
>>          * as that would do the wrong thing if the two directories
>>          * were the same, so again we do it by hand.
>>          */
>> -       fill_post_wcc(ffhp);
>> -       fill_post_wcc(tfhp);
>> +       if (!has_cached) {
>> +               fill_post_wcc(ffhp);
>> +               fill_post_wcc(tfhp);
>> +       }
>>         unlock_rename(tdentry, fdentry);
>>         ffhp->fh_locked = tfhp->fh_locked = 0;
>>         fh_drop_write(ffhp);
>>
>> +       /*
>> +        * If the target dentry has cached open files, then we need to try to
>> +        * close them prior to doing the rename. Flushing delayed fput
>> +        * shouldn't be done with locks held however, so we delay it until this
>> +        * point and then reattempt the whole shebang.
>> +        */
>> +       if (has_cached) {
>> +               has_cached = false;
>> +               nfsd_close_cached_files(ndentry);
>> +               dput(ndentry);
>> +               goto retry;
>> +       }
>>  out:
>>         return err;
>>  }
>> --
>> 2.4.3
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
