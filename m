Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:7365 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934661Ab3BNPnO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Feb 2013 10:43:14 -0500
Date: Thu, 14 Feb 2013 10:42:30 -0500
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: More fun with unmounting ESTALE directories.
Message-ID: <20130214104230.013b7f71@tlielax.poochiereds.net>
In-Reply-To: <20130212113813.427b8e05@notabene.brown>
References: <20130212113813.427b8e05@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 12 Feb 2013 11:38:13 +1100
NeilBrown <neilb@suse.de> wrote:

> 
> I've been exploring difficulties with unmounting stale directories and
> discovered another bug.
> 
> If I:
> 
> SERVER:  mkdir /foo/bar  #and make sure it is exported
> CLIENT:  mount -o vers=4 server:/foo/bar /mnt
> SERVER:  rm -r /foo
> CLIENT:  > /mnt/baz # gets an error of course
> CLIENT:  ls -l /mnt # error again
> CLIENT:  umount /mnt
> 
> The result of that last command is:
> 
> /mnt was not found in /proc/mounts
> /mnt was not found in /proc/mounts
> 
> Strange?
> 
> cat /proc/mounts
> 
> .....
> 10.0.2.2://foo/bar /mnt\040(deleted) nfs4 rw,relatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=10.0.2.15,minorversion=0,local_lock=none,addr=10.0.2.2 0 0
> ....
> 
> Notice the "\040(deleted)".
> 
> NFS has unhashed that directory because it is obviously bad, and d_path()
> notices and adds " (deleted)".
> 
> Now I might be able to argue that NFS shouldn't be unhashing a directory that
> is a mountpoint - it certainly seems strange behaviour.
> 
> But I think I can more strongly argue that /proc/mounts shouldn't be showing
> the mounted directory, but instead the directory that it is mounted on.
> Obviously these both have the same name so it shouldn't matter ... except
> that here is a case where it does.
> 
> I "fixed" it with
> 
> --- a/fs/proc_namespace.c
> +++ b/fs/proc_namespace.c
> @@ -93,7 +93,7 @@ static int show_vfsmnt(struct seq_file *m, struct vfsmount *mnt)
>  {
>  	struct mount *r = real_mount(mnt);
>  	int err = 0;
> -	struct path mnt_path = { .dentry = mnt->mnt_root, .mnt = mnt };
> +	struct path mnt_path = { .dentry = r->mnt_mountpoint, .mnt = &(r->mnt_parent)->mnt };
>  	struct super_block *sb = mnt_path.dentry->d_sb;
>  
>  	if (sb->s_op->show_devname) {
> 
> though I suspect that isn't safe and needs some locking.
> 
> Probably both should be fixed:  NFS should not invalidate any mounted
> directory, and show_vfsmnt() should report the mointpoint, not the mounted
> directory.
> 
> I can't figure out any way to get NFS to not invalidate the mounted directory.
> I think it happens in nfs_lookup_revalidate() when it calls d_drop(), but I
> don't know how to tell if a given dentry is a mnt_root for any mountpoint.
> 
> Suggestions?  Thoughts?
> 
> Thanks,
> NeilBrown
> 

I've also been looking at some weird ESTALE problems. Here's another
fun one that doesn't involve mountpoints. Assume here that we're
working in the same exported directory on client and server:

    server# mkdir a
    client# cd a
    server# mv a a.bak
    client# sleep 30  # (or whatever the dir attrcache timeout is)
    client# stat .
    stat: cannot stat ‘.’: Stale NFS file handle

Obviously, "." should not be stale. It got renamed, but the inode still
exists on the server.

If you sniff on the wire, you'll see that the server doesn't ever send
an ESTALE here. What happens is that due to FS_REVAL_DOT being set, we
end up trying to revalidate the dentry that "." refers to. We find that
the parent changed (obviously) and then try to redo the lookup of "a".
At that point we notice that it doesn't exist and turn it into ESTALE.

I don't really understand the point of FS_REVAL_DOT. What does that
actually buy us? I wonder if removing it would also help your testcase?

-- 
Jeff Layton <jlayton@redhat.com>
