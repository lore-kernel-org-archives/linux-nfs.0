Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:60844 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751936Ab2CGJ4M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Mar 2012 04:56:12 -0500
Received: by obbuo6 with SMTP id uo6so6685754obb.19
        for <linux-nfs@vger.kernel.org>; Wed, 07 Mar 2012 01:56:12 -0800 (PST)
Subject: Re: may i ask a question about nfs fs ? thanks a lot.
From: sword <histemiss@gmail.com>
To: wangjing <wangjing@300.cn>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
In-Reply-To: <201202020009007716206@300.cn>
References: <201202012212229514260@300.cn>  <201202020009007716206@300.cn>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 07 Mar 2012 18:11:27 +0800
Message-ID: <1331115087.2504.18.camel@jianli.nay.redhat.com>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

何不直接去掉sillyrename功能，反正要暴力删除文件。 放到/tmp不大可能。
cron应该在client, 否则怎能有删不掉的文件?! 把它放到server端吧... 

On Thu, 2012-02-02 at 00:09 +0800, wangjing wrote:
> may i ask a question? thanks a lot.
> 
> the background
>    1、Linux fs has   /nfsmnt/work_pub/web and /nfsmnt/work_inwork/web ，they use NFS V3 mount
>    2、there is many process will read and write files in the dir /nfsmnt/work_pub/web 
>    3、cron will del  all files in dir  /nfsmnt/work_pub/web in period，and will copy all the files which in the dir /nfsmnt/work_inwork/web 
> 
> in some times delete all files in  /nfsmnt/work_pub/web will faild ,because there is some .nfsXXXX
> 
> 
> 
> My question is :can i modify nfs_sillyrename funncion  in the fs/nfs/dir.c , general all .nfsXXX in /tmp,and make kernel ?
> 
> 
> 
> static int nfs_sillyrename(struct inode *dir, struct dentry *dentry)
> {
> static unsigned int sillycounter;
> const int      i_inosize  = sizeof(dir->i_ino)*2;
> const int      countersize = sizeof(sillycounter)*2;
> const int      slen       = strlen(".nfs") + i_inosize + countersize;
> char           silly[slen+1];
> struct qstr    qsilly;
> struct dentry *sdentry;
> int            error = -EIO;
> dfprintk(VFS, "NFS: silly-rename(%s/%s, ct=%d)\n",
> dentry->d_parent->d_name.name, dentry->d_name.name, 
> atomic_read(&dentry->d_count));
> if (atomic_read(&dentry->d_count) == 1)
> goto out;  /* No need to silly rename. */
> #ifdef NFS_PARANOIA
> if (!dentry->d_inode)
> printk("NFS: silly-renaming %s/%s, negative dentry??\n",
> dentry->d_parent->d_name.name, dentry->d_name.name);
> #endif
> /*
>  * We don't allow a dentry to be silly-renamed twice.
>  */
> error = -EBUSY;
> if (dentry->d_flags & DCACHE_NFSFS_RENAMED)
> goto out;
> sprintf(silly, ".nfs%*.*lx",
> i_inosize, i_inosize, dentry->d_inode->i_ino);
> sdentry = NULL;
> do {
> char *suffix = silly + slen - countersize;
> dput(sdentry);
> sillycounter++;
> sprintf(suffix, "%*.*x", countersize, countersize, sillycounter);
> dfprintk(VFS, "trying to rename %s to %s\n",
>  dentry->d_name.name, silly);
> sdentry = lookup_one(silly, dentry->d_parent);
> /*
>  * N.B. Better to return EBUSY here ... it could be
>  * dangerous to delete the file while it's in use.
>  */
> if (IS_ERR(sdentry))
> goto out;
> } while(sdentry->d_inode != NULL); /* need negative lookup */
> nfs_zap_caches(dir);
> qsilly.name = silly;
> qsilly.len  = strlen(silly);
> error = NFS_PROTO(dir)->rename(dir, &dentry->d_name, dir, &qsilly);  //can i modify this to solve my issiue  可否修改 此处代码来解决问题
> if (!error) {
> nfs_renew_times(dentry);
> d_move(dentry, sdentry);
> error = nfs_async_unlink(dentry);
>   /* If we return 0 we don't unlink */
> }
> dput(sdentry);
> out:
> return error;
> }
> 
> 
> 
> 
> 2012-02-01 
> wangjing
> NР骒rybX肚v^)藓{.n+伐{"^nr■zhㄨ&ⅧGh(茛j"m赇z罐帼f＂h~m


