From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: [ltt-dev] [PATCH] nfs: add support for splice writes
Date: Mon, 20 Apr 2009 11:09:15 +0530
Message-ID: <49EC0A83.8060802@suse.de>
References: <49D45974.2060202@suse.de> <20090402063235.GB24846@Krystal>	 <49D45E42.3050502@suse.de> <91e0b5050904020542l6b38d7a6hab6d7ef8b4593425@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mathieu Desnoyers <compudj@krystal.dyndns.org>,
	linux-nfs@vger.kernel.org, ltt-dev@lists.casi.polymtl.ca,
	Trond.Myklebust@netapp.com, LKML <linux-kernel@vger.kernel.org>,
	linux-embedded@vger.kernel.org
To: Masahiro Tamori <masahiro.tamori@gmail.com>
Return-path: <linux-embedded-owner@vger.kernel.org>
In-Reply-To: <91e0b5050904020542l6b38d7a6hab6d7ef8b4593425@mail.gmail.com>
Sender: linux-embedded-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

Do you think this patch is OK? Can this be considered for merging?

Thanks,

Masahiro Tamori wrote:
> Hello Suresh and Mathieu,
> 
> 2009/4/2 Suresh Jayaraman <sjayaraman@suse.de>:
>> Mathieu Desnoyers wrote:
>>> * Suresh Jayaraman (sjayaraman@suse.de) wrote:
>>>> This patch attempts to add splice writes support. In essence, it just
>>>> calls generic_file_splice_write() after doing a little sanity check.
>>>> This would allow LTTng users that are using NFS to store trace data.
>>>> There could be more applications that could be benefitted too.
>>>>
>>>> I have tested this using the Jens' test program and have found no
>>>> real issues. The test program is inlined below:
>>>>
>>> There is just a small checkpatch nit that I'll fix directly in place in
>>> the LTTng tree.
>>>
>>> WARNING: %Ld/%Lu are not-standard C, use %lld/%llu
>>> #93: FILE: fs/nfs/file.c:564:
>>> +   dprintk("NFS splice_write(%s/%s, %lu@%Lu)\n",
>>>
>>> total: 0 errors, 1 warnings, 42 lines checked
>>>
>> Yes, I noticed it. There are quite a few places in nfs code where we
>> happened to use that (that doesn't imply that it shouldn't be fixed), so
>> I thought it's OK.
>>
>>> That's great ! I'll pull it in the LTTng tree so my users can try it.
>>> They currently cannot write LTTng traces to NFS mounts anyway.
>> Yes, please report the test results. Would appreciate it very much.
>>
>>
>> Thanks,
> 
> Thank you for creating a patch !!
> 
> I tested it, and it works fine.
> 
> My environment is following,
> LTTV 0.12.10
> LTTng 0.100
> LTT Control 0.65
> Kernles 2.6.29
> 
> LTTng version is old now, but the test is passed on ARM11 target.
> 
> Furthermore, I run the splice test and the test is passed too.
> The test code is copied from
> http://kzk9.net/blog/2007/05/splice2.html
> (Japanese page)
> 
> Thanks all people who commented this issue.
> 
> Best regards,
> Masahiro Tamori
> 
>>>> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
>>>> index 90f292b..13d6a00 100644
>>>> --- a/fs/nfs/file.c
>>>> +++ b/fs/nfs/file.c
>>>> @@ -47,6 +47,9 @@ static ssize_t nfs_file_splice_read(struct file *filp, loff_t *ppos,
>>>>                   size_t count, unsigned int flags);
>>>> static ssize_t nfs_file_read(struct kiocb *, const struct iovec *iov,
>>>>               unsigned long nr_segs, loff_t pos);
>>>> +static ssize_t nfs_file_splice_write(struct pipe_inode_info *pipe,
>>>> +                  struct file *filp, loff_t *ppos,
>>>> +                  size_t count, unsigned int flags);
>>>> static ssize_t nfs_file_write(struct kiocb *, const struct iovec *iov,
>>>>               unsigned long nr_segs, loff_t pos);
>>>> static int nfs_file_flush(struct file *, fl_owner_t id);
>>>> @@ -76,6 +79,7 @@ const struct file_operations nfs_file_operations = {
>>>>   .lock      = nfs_lock,
>>>>   .flock     = nfs_flock,
>>>>   .splice_read  = nfs_file_splice_read,
>>>> +  .splice_write  = nfs_file_splice_write,
>>>>   .check_flags  = nfs_check_flags,
>>>>   .setlease    = nfs_setlease,
>>>> };
>>>> @@ -550,6 +554,26 @@ out_swapfile:
>>>>   goto out;
>>>> }
>>>>
>>>> +static ssize_t nfs_file_splice_write(struct pipe_inode_info *pipe,
>>>> +                 struct file *filp, loff_t *ppos,
>>>> +                 size_t count, unsigned int flags)
>>>> +{
>>>> +  struct dentry *dentry = filp->f_path.dentry;
>>>> +  struct inode *inode = dentry->d_inode;
>>>> +
>>>> +  dprintk("NFS splice_write(%s/%s, %lu@%Lu)\n",
>>>> +      dentry->d_parent->d_name.name, dentry->d_name.name,
>>>> +      (unsigned long) count, (unsigned long long) *ppos);
>>>> +
>>>> +  if (IS_SWAPFILE(inode)) {
>>>> +      printk(KERN_INFO "NFS: attempt to write to active swap"
>>>> +          "file!\n");
>>>> +      return -EBUSY;
>>>> +  }
>>>> +
>>>> +  return generic_file_splice_write(pipe, filp, ppos, count, flags);
>>>> +}
>>>> +
>>>> static int do_getlk(struct file *filp, int cmd, struct file_lock *fl)
>>>> {
>>>>   struct inode *inode = filp->f_mapping->host;
>>>>
>>
>> --
>> Suresh Jayaraman
>>
>> _______________________________________________
>> ltt-dev mailing list
>> ltt-dev@lists.casi.polymtl.ca
>> http://lists.casi.polymtl.ca/cgi-bin/mailman/listinfo/ltt-dev
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Suresh Jayaraman
