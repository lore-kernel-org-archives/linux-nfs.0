Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:60762 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752560Ab0KWUzZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Nov 2010 15:55:25 -0500
Received: by gxk22 with SMTP id 22so304119gxk.19
        for <linux-nfs@vger.kernel.org>; Tue, 23 Nov 2010 12:55:25 -0800 (PST)
In-Reply-To: <20101119235717.GE12783@fieldses.org>
References: <AANLkTim3GyG4Skr_=0QyELJw1ySjfvhYMD2g4JKztrOx@mail.gmail.com>
	<20101116185551.GD3971@fieldses.org>
	<AANLkTik=WkedMyy=oVorEuSW96vTdK7vBnneOTe1qgxh@mail.gmail.com>
	<20101119235717.GE12783@fieldses.org>
Date: Tue, 23 Nov 2010 14:55:24 -0600
Message-ID: <AANLkTimvvbDw+YYoK8ZuKt3fJHTjxrJgWhq7r9ucHjwo@mail.gmail.com>
Subject: Re: incorrect EXDEV error occasionally returned for rename over NFS
From: Joe Habermann <joe.habermann@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Sure, I'll take another look.  I definitely would prefer a more
elegant solution.

With regard to the strcmp on ex_client->name(), I'm not sure that's 100% tight.
Suppose we have an export such as:
    *(rw,sync,no_subtree_check)
And during the race window, that export is replaced with:
    foo(rw,sync,no_subtree_check)
And it's "foo" that's performing the rename.
In this case, the export pointers will (generally) be different, as
will the auth_domain pointers, as will the string pointed to by
ex_client->name ("*" vs. "foo"), incorrectly leading to a failing
check.

-Joe

On Fri, Nov 19, 2010 at 5:57 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Wed, Nov 17, 2010 at 05:39:01PM -0600, Joe Habermann wrote:
>> OK, so I think I have an approach that may work and not require major
>> refactoring.  The basic idea is to maintain a sequence number for the
>> svc_export_cache.  We snap the sequence at the top of nfsd_rename.
>> And we snap it again after we've called fh_verify for the "to" directory.
>> If the sequence number changed, then the cache changed and trying
>> to compare the export pointers can lead to false positives or false negatives.
>> In this case, throw away export and the dentry information and start over.
>>
>> Other changes:
>> 1) got rid of "inuse" in cache_detail.  It really wasn't being used.
>> 2) Remove check for ex_path.mnt near the bottom of nfsd_rename.
>> Can't we assert that ffhp->fh_export == tfhp->fh_export?
>> 3) Threw in a stat to see how often we have to retry ("rename_retries")
>>
>> I'm testing with this now and so far so good but
>> comments/corrections/suggestions
>> welcome since I'm very new to this code.
>
> Hm, thanks, that looks like an approach that should work.
>
> It sure would be simpler, though if we could just solve the problem by
> replacing the comparison of export pointers by a better comparison....
>
> I understand your concern about svc_export_match--I'd need to reread
> some code to figure out if we can have duplicate auth_domains in the
> same way we can with exports--but if so we can always just do a strcmp()
> of the ex_client->name's instead.
>
> How about trying that?  Just define a small helper function that does
> those checks, and call it from rename in place of the export
> comparisons?
>
> --b.
>
>>
>> Thanks, -Joe
>>
>> --- ../linux-2.6.32.12-0.7/./include/linux/sunrpc/cache.h
>> 2010-05-20 05:06:54.000000000 -0500
>> +++ ./include/linux/sunrpc/cache.h      2011-02-11 16:04:19.000000000 -0600
>> @@ -74,7 +74,8 @@ struct cache_detail {
>>         struct cache_head **    hash_table;
>>         rwlock_t                hash_lock;
>>
>> -       atomic_t                inuse; /* active user-space update or lookup */
>> +       atomic_t                seqno; /* bumped when cache changes
>> +                                       * not used by all caches */
>>
>>         char                    *name;
>>         void                    (*cache_put)(struct kref *);
>> --- ../linux-2.6.32.12-0.7/./net/sunrpc/cache.c 2010-05-20
>> 05:06:54.000000000 -0500
>> +++ ./net/sunrpc/cache.c        2011-02-11 20:03:55.000000000 -0600
>> @@ -96,6 +96,7 @@ struct cache_head *sunrpc_cache_lookup(s
>>         *head = new;
>>         detail->entries++;
>>         cache_get(new);
>> +       atomic_inc(&detail->seqno);
>>         write_unlock(&detail->hash_lock);
>>
>>         return new;
>> @@ -141,6 +142,7 @@ struct cache_head *sunrpc_cache_update(s
>>                         cache_fresh_locked(old, new->expiry_time);
>>                         write_unlock(&detail->hash_lock);
>>                         cache_fresh_unlocked(old, detail);
>> +                       atomic_inc(&detail->seqno);
>>                         return old;
>>                 }
>>                 write_unlock(&detail->hash_lock);
>> @@ -170,6 +172,7 @@ struct cache_head *sunrpc_cache_update(s
>>         cache_fresh_unlocked(tmp, detail);
>>         cache_fresh_unlocked(old, detail);
>>         cache_put(old, detail);
>> +       atomic_inc(&detail->seqno);
>>         return tmp;
>>  }
>>  EXPORT_SYMBOL_GPL(sunrpc_cache_update);
>> @@ -241,11 +244,13 @@ int cache_check(struct cache_detail *det
>>                                         cache_fresh_unlocked(h, detail);
>>                                         rv = -ENOENT;
>>                                 }
>> +                               atomic_inc(&detail->seqno);
>>                                 break;
>>
>>                         case -EAGAIN:
>>                                 clear_bit(CACHE_PENDING, &h->flags);
>>                                 cache_revisit_request(h);
>> +                               atomic_inc(&detail->seqno); /* not needed? */
>>                                 break;
>>                         }
>>                 }
>> @@ -327,7 +332,7 @@ static void sunrpc_destroy_cache_detail(
>>         cache_purge(cd);
>>         spin_lock(&cache_list_lock);
>>         write_lock(&cd->hash_lock);
>> -       if (cd->entries || atomic_read(&cd->inuse)) {
>> +       if (cd->entries) {
>>                 write_unlock(&cd->hash_lock);
>>                 spin_unlock(&cache_list_lock);
>>                 goto out;
>> --- ../linux-2.6.32.12-0.7/./fs/nfsd/vfs.c      2010-05-20
>> 05:06:54.000000000 -0500
>> +++ ./fs/nfsd/vfs.c     2011-02-11 16:03:24.000000000 -0600
>> @@ -1717,6 +1717,8 @@ out_nfserr:
>>         goto out_unlock;
>>  }
>>
>> +static atomic_t rename_retries = ATOMIC_INIT(0);
>> +
>>  /*
>>   * Rename a file
>>   * N.B. After this call _both_ ffhp and tfhp need an fh_put
>> @@ -1729,14 +1731,33 @@ nfsd_rename(struct svc_rqst *rqstp, stru
>>         struct inode    *fdir, *tdir;
>>         __be32          err;
>>         int             host_err;
>> +       int             seqsav;
>>
>> +retry:
>> +       seqsav = atomic_read(&svc_export_cache.seqno);
>>         err = fh_verify(rqstp, ffhp, S_IFDIR, NFSD_MAY_REMOVE);
>>         if (err)
>>                 goto out;
>>         err = fh_verify(rqstp, tfhp, S_IFDIR, NFSD_MAY_CREATE);
>>         if (err)
>>                 goto out;
>>
>> +       /* if cache changed, the fh_export pointer comparison
>> +        * below is not valid, in general */
>> +       if (unlikely(seqsav != atomic_read(&svc_export_cache.seqno))) {
>> +               cache_put(&ffhp->fh_export->h, &svc_export_cache);
>> +               ffhp->fh_export = NULL;
>> +               cache_put(&tfhp->fh_export->h, &svc_export_cache);
>> +               tfhp->fh_export = NULL;
>> +               dput(ffhp->fh_dentry);
>> +               ffhp->fh_dentry = NULL;
>> +               dput(tfhp->fh_dentry);
>> +               tfhp->fh_dentry = NULL;
>> +               atomic_inc(&rename_retries);
>> +               goto retry;
>> +       }
>> +
>>         fdentry = ffhp->fh_dentry;
>>         fdir = fdentry->d_inode;
>>
>> @@ -1785,9 +1806,6 @@ nfsd_rename(struct svc_rqst *rqstp, stru
>>                         goto out_dput_new;
>>         }
>>
>> -       host_err = -EXDEV;
>> -       if (ffhp->fh_export->ex_path.mnt != tfhp->fh_export->ex_path.mnt)
>> -               goto out_dput_new;
>>         host_err = mnt_want_write(ffhp->fh_export->ex_path.mnt);
>>         if (host_err)
>>                 goto out_dput_new;
>>
>>
>> On Tue, Nov 16, 2010 at 12:55 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> > On Mon, Nov 15, 2010 at 03:46:44PM -0600, Joe Habermann wrote:
>> >> When running SVN checkouts over NFSv3, they occasionally fail with an
>> >> EXDEV error:
>> >>
>> >> (etc.)
>> >> U    snfs/build/Makefile.hpux
>> >> svn: In directory 'snfs/build'
>> >> svn: Can't move 'snfs/build/tempfile.tmp' to
>> >> 'snfs/build/Makefile.sol': Invalid cross-device link
>> >>
>> >> I've noticed that other people have reported this problem but it remains
>> >> unresolved.  Through some debugging, I believe I have found root cause.
>> >> nfsd_rename() contains the following code:
>> >>
>> >> 1707 /*
>> >> 1708  * Rename a file
>> >> 1709  * N.B. After this call _both_ ffhp and tfhp need an fh_put 1710  */
>> >> 1711 __be32
>> >> 1712 nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char
>> >> *fname, int flen,
>> >> 1713                             struct svc_fh *tfhp, char *tname, int tlen)
>> >> 1714 {
>> >> 1715         struct dentry   *fdentry, *tdentry, *odentry, *ndentry, *trap;
>> >> 1716         struct inode    *fdir, *tdir;
>> >> 1717         __be32          err;
>> >> 1718         int             host_err;
>> >> 1719
>> >> 1720         err = fh_verify(rqstp, ffhp, S_IFDIR, NFSD_MAY_REMOVE);
>> >> 1721         if (err)
>> >> 1722                 goto out;
>> >> 1723         err = fh_verify(rqstp, tfhp, S_IFDIR, NFSD_MAY_CREATE);
>> >> 1724         if (err)
>> >> 1725                 goto out;
>> >> 1726
>> >> 1727         fdentry = ffhp->fh_dentry;
>> >> 1728         fdir = fdentry->d_inode;
>> >> 1729
>> >> 1730         tdentry = tfhp->fh_dentry;
>> >> 1731         tdir = tdentry->d_inode;
>> >> 1732
>> >> 1733         err = (rqstp->rq_vers == 2) ? nfserr_acces : nfserr_xdev;
>> >> 1734         if (ffhp->fh_export != tfhp->fh_export)
>> >> 1735                 goto out;
>> >>
>> >> Line 1734 compares the fh_export pointers in the file handles for
>> >> the "from" and "to" directories.  However, this is a bad check since
>> >> it's possible these pointers differ yet refer to the same underlying
>> >> file system.  Based on code inspection, encached export pointers are
>> >> only valid for 30 minutes before they expire and are reinserted through
>> >> calls made between the kernel and rpc.mountd.  So a race exists where the
>> >> ffhp->fh_export is populated on line 1720, the export cache is updated,
>> >> and tfhp->fh_export is set on line 1723 to a different value.
>> >>
>> >> This window can be cranked wide open by putting an "msleep(10);"
>> >> between lines 1722 and 1723 above, recompiling and reinstalling nfsd.ko
>> >> etc., and then running SVN checkouts in a loop from an NFS client.
>> >> Within 30 minutes, the problem is seen.
>> >
>> > Good detective work, thanks.  Have you confirmed that applying your
>> > change below eliminates the problem?
>> >
>> >> I'm still very new to the NFS code, but I'm wonder whether the check
>> >> needs to be something like this instead:
>> >>
>> >> --- vfs.c.orig  2010-11-15 14:35:18.000000000 -0600
>> >> +++ vfs.c       2010-11-15 14:43:52.000000000 -0600
>> >> @@ -1731,7 +1731,7 @@ nfsd_rename(struct svc_rqst *rqstp, stru
>> >>    tdir = tdentry->d_inode;
>> >>
>> >>    err = (rqstp->rq_vers == 2) ? nfserr_acces : nfserr_xdev;
>> >> -       if (ffhp->fh_export != tfhp->fh_export)
>> >> +       if (fdir->i_sb != tdir->i_sb)
>> >>        goto out;
>> >>
>> >>    err = nfserr_perm;
>> >>
>> >> Thoughts?  I think it's either that or some locking needs to be put in
>> >> to guarantee that the file handles for the "to" and "from" directory
>> >> always wind up with the same export pointer when they belong to the
>> >> same file system.  I guess the other question is why there is an
>> >> EXDEV check at the top of nfsd_rename() instead of putting it in
>> >> vfs_rename().
>> >
>> > The fh_verify call is also responsible for setting the identity of the
>> > user, and that may be affected by export options like root_squash.  In
>> > the above case if ffhp was on a root_squash export, and tfhp on a
>> > no_root_squash export, and we get a request from uid 0, we'd end up
>> > with an incoming uid-0 user running as root (since the fh_verify for
>> > tfhp was performed last), and might allow renaming from a directory that
>> > only root had write permission to.
>> >
>> > It's a minor hole (especially since it's already easy for a client to
>> > circumvent protections that vary from export to export in the default
>> > no_subtree_check case).  But we should be able to do better.
>> >
>> > I'm not sure what to suggest.
>> >
>> > --b.
>> >
>> >>
>> >> For full disclosure, I'm actually running the SLES11 SP1 kernel,
>> >> linux-2.6.32.12-0.7, but I've looked at the latest upstream kernels and
>> >> they appear to have the same code and I assume the same issue.
>> >
>
