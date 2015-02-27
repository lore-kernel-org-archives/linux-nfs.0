Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:33205 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753016AbbB0UZH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Feb 2015 15:25:07 -0500
Received: by mail-vc0-f174.google.com with SMTP id id10so7263602vcb.5
        for <linux-nfs@vger.kernel.org>; Fri, 27 Feb 2015 12:25:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <47B66753-080A-4B8F-8F31-ACE76447EF55@oracle.com>
References: <1425009509-3809-1-git-send-email-trond.myklebust@primarydata.com>
	<47B66753-080A-4B8F-8F31-ACE76447EF55@oracle.com>
Date: Fri, 27 Feb 2015 15:25:06 -0500
Message-ID: <CAHQdGtRyAWCTKajL_h3Er187Mwey25HxfXe6W0XM2MH-3-Q=5A@mail.gmail.com>
Subject: Re: [PATCH v2 1/8] NFS: Add a helper to set attribute barriers
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 27, 2015 at 3:16 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> On Feb 26, 2015, at 10:58 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>> fs/nfs/inode.c         | 16 ++++++++++++++++
>> include/linux/nfs_fs.h |  1 +
>> 2 files changed, 17 insertions(+)
>>
>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>> index 83107be3dd01..b0cbc1ba82da 100644
>> --- a/fs/nfs/inode.c
>> +++ b/fs/nfs/inode.c
>> @@ -1260,6 +1260,22 @@ void nfs_fattr_init(struct nfs_fattr *fattr)
>> }
>> EXPORT_SYMBOL_GPL(nfs_fattr_init);
>>
>> +/**
>> + * nfs_fattr_set_barrier
>> + * @fattr: attributes
>> + *
>> + * Used to set a barrier after an attribute was updated. This
>> + * barrier ensures that older attributes from RPC calls that may
>> + * have raced with our update cannot clobber these new values.
>> + * Note that you are still responsible for ensuring that other
>> + * operations which change the attribute on the server do not
>> + * collide.
>> + */
>> +void nfs_fattr_set_barrier(struct nfs_fattr *fattr)
>> +{
>> +     fattr->gencount = nfs_inc_attr_generation_counter();
>> +}
>> +
>> struct nfs_fattr *nfs_alloc_fattr(void)
>> {
>>       struct nfs_fattr *fattr;
>> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
>> index 2f77e0c651c8..3a4ffb5856cd 100644
>> --- a/include/linux/nfs_fs.h
>> +++ b/include/linux/nfs_fs.h
>> @@ -369,6 +369,7 @@ extern struct nfs_lock_context *nfs_get_lock_context(struct nfs_open_context *ct
>> extern void nfs_put_lock_context(struct nfs_lock_context *l_ctx);
>> extern u64 nfs_compat_user_ino64(u64 fileid);
>> extern void nfs_fattr_init(struct nfs_fattr *fattr);
>> +extern void nfs_fattr_set_barrier(struct nfs_fattr *fattr);
>> extern unsigned long nfs_inc_attr_generation_counter(void);
>>
>> extern struct nfs_fattr *nfs_alloc_fattr(void);
>> --
>> 2.1.0
>>
>
> I applied all 8 patches in this series to 3.19.0. I tested against
> Solaris 11, Solaris 12 pre-release, and Linux 3.19 servers.
>
> With NFSv3, during full runs of xfstests, I was not able to reproduce
> the fsx failures I described with any fsx-related test, but more
> test runs are needed to lend better confidence that the issue is
> addressed. (It looks good so far).
>
> A new failure occurred with Solaris 11 server, not with the other two.
> I’ve never seen this one before. I will see if it’s reproducible.
>
> generic/207 1s ... [failed, exit status 1] - output mismatch (see /home/cel/src/xfstests/results//generic/207.out.bad)
>     --- tests/generic/207.out   2014-02-13 15:40:45.204103195 -0500
>     +++ /home/cel/src/xfstests/results//generic/207.out.bad     2015-02-27 11:55:47.943262225 -0500
>     @@ -1,2 +1,2 @@
>      QA output created by 207
>     -4000 iterations of racing extensions and collection passed
>     +write of 4096 bytes @16379904 finished, expected filesize at least 16384000, but got 16379904

Huh. I'll look into this.

>     ...
>     (Run 'diff -u tests/generic/207.out /home/cel/src/xfstests/results//generic/207.out.bad'  to see the entire diff)
>
> With NFSv4, starting xfstests triggers an immediate panic, 100%
> reproducible. I’ve attached a photo of the console. I can investigate
> further if you want me to.

Oh crap... I forgot that nfs4_proc_write_setup() can unset
hdr->res.fattr. I'll add an appropriate check to
nfs_writeback_update_inode().

Thanks for testing!

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
