Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:36699 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751510AbbHTQJO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2015 12:09:14 -0400
MIME-Version: 1.0
In-Reply-To: <20150812142815.27968b32@tlielax.poochiereds.net>
References: <cover.1439375087.git.viresh.kumar@linaro.org> <2efb962cb72884f625116cba24fc4fb203c6621f.1439375087.git.viresh.kumar@linaro.org>
 <20150812142815.27968b32@tlielax.poochiereds.net>
From: Steve French <smfrench@gmail.com>
Date: Thu, 20 Aug 2015 11:08:53 -0500
Message-ID: <CAH2r5mvUC2WO6sVqhe_QCgiCJbRbahDsSj=-Uzk7LB_peTqjLQ@mail.gmail.com>
Subject: Re: [PATCH V1 Resend 07/10] fs: Drop unlikely before IS_ERR(_OR_NULL)
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Viresh Kumar <viresh.kumar@linaro.org>, Boaz Harrosh <ooo@electrozaur.com>,
        <linux-nfs@vger.kernel.org>, linaro-kernel@lists.linaro.org,
        Jiri Kosina <trivial@kernel.org>,
        "open list:COMMON INTERNET FILE SYSTEM CIFS"
	<linux-cifs@vger.kernel.org>,
        "open list:ECRYPT FILE SYSTEM" <ecryptfs@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>,
        David Howells <dhowells@redhat.com>,
        "open list:FILESYSTEMS VFS and infrastructure"
	<linux-fsdevel@vger.kernel.org>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Fabian Frederick <fabf@skynet.be>,
        Andrew Morton <akpm@linux-foundation.org>,
        "open list:EXT4 FILE SYSTEM" <linux-ext4@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 12, 2015 at 1:28 PM, Jeff Layton <jlayton@poochiereds.net> wrote:
> On Wed, 12 Aug 2015 15:59:44 +0530
> Viresh Kumar <viresh.kumar@linaro.org> wrote:
>
>> IS_ERR(_OR_NULL) already contain an 'unlikely' compiler flag and there
>> is no need to do that again from its callers. Drop it.
>>
>> Reviewed-by: David Howells <dhowells@redhat.com>
>> Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
>> ---
>>  fs/cifs/readdir.c            | 2 +-
>>  fs/ecryptfs/inode.c          | 2 +-
>>  fs/ext4/extents.c            | 6 +++---
>>  fs/ext4/namei.c              | 2 +-
>>  fs/namei.c                   | 4 ++--
>>  fs/ncpfs/dir.c               | 2 +-
>>  fs/nfs/objlayout/objio_osd.c | 2 +-
>>  fs/proc/proc_sysctl.c        | 2 +-
>>  8 files changed, 11 insertions(+), 11 deletions(-)
>>
>> diff --git a/fs/cifs/readdir.c b/fs/cifs/readdir.c
>> index b1eede3678a9..0557c45e9c33 100644
>> --- a/fs/cifs/readdir.c
>> +++ b/fs/cifs/readdir.c
>> @@ -84,7 +84,7 @@ cifs_prime_dcache(struct dentry *parent, struct qstr *name,
>>       cifs_dbg(FYI, "%s: for %s\n", __func__, name->name);
>>
>>       dentry = d_hash_and_lookup(parent, name);
>> -     if (unlikely(IS_ERR(dentry)))
>> +     if (IS_ERR(dentry))
>>               return;
>>
>>       if (dentry) {
>> diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
>> index 3c4db1172d22..e2e47ba5d313 100644
>> --- a/fs/ecryptfs/inode.c
>> +++ b/fs/ecryptfs/inode.c
>> @@ -270,7 +270,7 @@ ecryptfs_create(struct inode *directory_inode, struct dentry *ecryptfs_dentry,
>>
>>       ecryptfs_inode = ecryptfs_do_create(directory_inode, ecryptfs_dentry,
>>                                           mode);
>> -     if (unlikely(IS_ERR(ecryptfs_inode))) {
>> +     if (IS_ERR(ecryptfs_inode)) {
>>               ecryptfs_printk(KERN_WARNING, "Failed to create file in"
>>                               "lower filesystem\n");
>>               rc = PTR_ERR(ecryptfs_inode);
>> diff --git a/fs/ext4/extents.c b/fs/ext4/extents.c
>> index 2553aa8b608d..799f01714767 100644
>> --- a/fs/ext4/extents.c
>> +++ b/fs/ext4/extents.c
>> @@ -899,7 +899,7 @@ ext4_find_extent(struct inode *inode, ext4_lblk_t block,
>>
>>               bh = read_extent_tree_block(inode, path[ppos].p_block, --i,
>>                                           flags);
>> -             if (unlikely(IS_ERR(bh))) {
>> +             if (IS_ERR(bh)) {
>>                       ret = PTR_ERR(bh);
>>                       goto err;
>>               }
>> @@ -5792,7 +5792,7 @@ ext4_swap_extents(handle_t *handle, struct inode *inode1,
>>               int split = 0;
>>
>>               path1 = ext4_find_extent(inode1, lblk1, NULL, EXT4_EX_NOCACHE);
>> -             if (unlikely(IS_ERR(path1))) {
>> +             if (IS_ERR(path1)) {
>>                       *erp = PTR_ERR(path1);
>>                       path1 = NULL;
>>               finish:
>> @@ -5800,7 +5800,7 @@ ext4_swap_extents(handle_t *handle, struct inode *inode1,
>>                       goto repeat;
>>               }
>>               path2 = ext4_find_extent(inode2, lblk2, NULL, EXT4_EX_NOCACHE);
>> -             if (unlikely(IS_ERR(path2))) {
>> +             if (IS_ERR(path2)) {
>>                       *erp = PTR_ERR(path2);
>>                       path2 = NULL;
>>                       goto finish;
>> diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
>> index 9f61e7679a6d..f12b277ad2af 100644
>> --- a/fs/ext4/namei.c
>> +++ b/fs/ext4/namei.c
>> @@ -1429,7 +1429,7 @@ static struct buffer_head * ext4_find_entry (struct inode *dir,
>>                               }
>>                               num++;
>>                               bh = ext4_getblk(NULL, dir, b++, 0);
>> -                             if (unlikely(IS_ERR(bh))) {
>> +                             if (IS_ERR(bh)) {
>>                                       if (ra_max == 0) {
>>                                               ret = bh;
>>                                               goto cleanup_and_exit;
>> diff --git a/fs/namei.c b/fs/namei.c
>> index cacc51ddcf54..67d419e55547 100644
>> --- a/fs/namei.c
>> +++ b/fs/namei.c
>> @@ -1942,7 +1942,7 @@ static int link_path_walk(const char *name, struct nameidata *nd)
>>               if (err) {
>>                       const char *s = get_link(nd);
>>
>> -                     if (unlikely(IS_ERR(s)))
>> +                     if (IS_ERR(s))
>>                               return PTR_ERR(s);
>>                       err = 0;
>>                       if (unlikely(!s)) {
>> @@ -3430,7 +3430,7 @@ struct file *do_file_open_root(struct dentry *dentry, struct vfsmount *mnt,
>>               return ERR_PTR(-ELOOP);
>>
>>       filename = getname_kernel(name);
>> -     if (unlikely(IS_ERR(filename)))
>> +     if (IS_ERR(filename))
>>               return ERR_CAST(filename);
>>
>>       set_nameidata(&nd, -1, filename);
>> diff --git a/fs/ncpfs/dir.c b/fs/ncpfs/dir.c
>> index 93575e91a7aa..356816e7bc90 100644
>> --- a/fs/ncpfs/dir.c
>> +++ b/fs/ncpfs/dir.c
>> @@ -597,7 +597,7 @@ ncp_fill_cache(struct file *file, struct dir_context *ctx,
>>       qname.name = __name;
>>
>>       newdent = d_hash_and_lookup(dentry, &qname);
>> -     if (unlikely(IS_ERR(newdent)))
>> +     if (IS_ERR(newdent))
>>               goto end_advance;
>>       if (!newdent) {
>>               newdent = d_alloc(dentry, &qname);
>> diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
>> index 5aaed363556a..5c0c6b58157f 100644
>> --- a/fs/nfs/objlayout/objio_osd.c
>> +++ b/fs/nfs/objlayout/objio_osd.c
>> @@ -124,7 +124,7 @@ objio_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
>>
>>  retry_lookup:
>>       od = osduld_info_lookup(&odi);
>> -     if (unlikely(IS_ERR(od))) {
>> +     if (IS_ERR(od)) {
>>               err = PTR_ERR(od);
>>               dprintk("%s: osduld_info_lookup => %d\n", __func__, err);
>>               if (err == -ENODEV && retry_flag) {
>> diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
>> index fdda62e6115e..fe5b6e6c4671 100644
>> --- a/fs/proc/proc_sysctl.c
>> +++ b/fs/proc/proc_sysctl.c
>> @@ -948,7 +948,7 @@ static struct ctl_dir *get_subdir(struct ctl_dir *dir,
>>  found:
>>       subdir->header.nreg++;
>>  failed:
>> -     if (unlikely(IS_ERR(subdir))) {
>> +     if (IS_ERR(subdir)) {
>>               pr_err("sysctl could not get directory: ");
>>               sysctl_print_dir(dir);
>>               pr_cont("/%*.*s %ld\n",
>
> Looks fine to me. You can add:
>
>     Reviewed-by: Jeff Layton <jlayton@poochiereds.net>
>
> ...but the problem is that you have a patch here that touches several
> different filesystems. You'll have to find someone willing to take it
> into some overarching tree (Al's perhaps, or maybe Andrew's?), or break
> it up into several per-fs patches and shepherd it into different
> maintainers' trees.

Reviewed-by: Steve French <smfrench@gmail.com>

Do you want me to merge the fs/cifs part of this independently (into
cifs-2.6.git staging tree) or are you going to merge all of this
(which changes multiple fs) at one time through someone else's tree?



-- 
Thanks,

Steve
