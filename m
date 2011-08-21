Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60937 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752719Ab1HUW3V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 21 Aug 2011 18:29:21 -0400
Date: Mon, 22 Aug 2011 08:29:10 +1000
From: NeilBrown <neilb@suse.de>
To: Sylvain Rochet <gradator@gradator.net>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: PROBLEM: 2.6.35.7 to 3.0 Inotify events missing
Message-ID: <20110822082910.25f5a0d8@notabene.brown>
In-Reply-To: <20110819230344.GA24784@gradator.net>
References: <20101018223540.GA20730@gradator.net>
	<20110819230344.GA24784@gradator.net>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 20 Aug 2011 01:03:44 +0200 Sylvain Rochet <gradator@gradator.net>
wrote:

> Hi,
> 
> On Tue, Oct 19, 2010 at 12:35:40AM +0200, Sylvain Rochet wrote:
> > 
> > ... upgraded to 2.6.33.5, then 2.6.33.7, finally to 2.6.35.7, and I 
> > always end up with the same ending, it seems inotify can miss some VFS 
> > events from time to time.
> 
> I finally find out why.
> 
> The NFS server does not always know the name of the modified file, if 
> the modified inode was cleared from the VFS cache fsnotify does not know 
> as well the filename then inotify child events on directories are 
> silently tossed.

This may not be helpful but if you export the filesystem with the
"subtree_check" option then the NFS server will always know a name for any
file that it modifies.

This is not without cost though, which is why it is no longer the default.

If the client opens a file, the server moves it to a new directory and then
the server cache is flushed, then the client will get an ESTALE error.  This
is rarely a problem in practice but when it is it can be quite annoying...

NeilBrown



> 
> Easy way to reproduce:
> 
> Add a few printk debug (here it only works if /data is the NFS export):
> 
> --- begin//fs/nfsd/vfs.c        2011-07-22 04:17:23.000000000 +0200
> +++ linux-3.0/fs/nfsd/vfs.c     2011-07-30 03:18:17.837560809 +0200
> @@ -975,6 +975,8 @@
>         inode = dentry->d_inode;
>         exp   = fhp->fh_export;
>  
> +       printk("nfsd write inode=%ld name=%s\n", inode->i_ino, dentry->d_name.name);
> +
>         /*
>          * Request sync writes if
>          *  -   the sync export option has been set, or
> 
> diff -Nru begin//include/linux/fsnotify.h linux-3.0/include/linux/fsnotify.h
> --- begin//include/linux/fsnotify.h     2011-07-22 04:17:23.000000000 +0200
> +++ linux-3.0/include/linux/fsnotify.h  2011-07-30 03:07:00.330239062 +0200
> @@ -216,8 +232,15 @@
>                 mask |= FS_ISDIR;
>  
>         if (!(file->f_mode & FMODE_NONOTIFY)) {
> +               if( !strcmp(path->mnt->mnt_mountpoint->d_name.name, "data") )
> +                       printk("fsnotify modify inode=%ld name=%s\n", inode->i_ino, file->f_dentry->d_name.name);
>                 fsnotify_parent(path, NULL, mask);
>                 fsnotify(inode, mask, path, FSNOTIFY_EVENT_PATH, NULL, 0);
> +       } else {
> +               if( !strcmp(path->mnt->mnt_mountpoint->d_name.name, "data") )
> +                       printk("fsnotify modify-nonotify inode=%ld name=%s\n", inode->i_ino, file->f_dentry->d_name.name);
>         }
>  }
> 
> 
> On the NFS client, open a fd and send some data:
> 
> # exec 1> test
> # ls -la
> # 
> 
> On the NFS server, check the kern log:
> 
> Aug 20 00:57:44 inotifydebug kernel: nfsd write inode=13 name=test
> Aug 20 00:57:44 inotifydebug kernel: fsnotify modify inode=13 name=test
> 
> Everything goes well.
> 
> Now, clear the VFS cache on the NFS server:
> 
> # echo 3 > /proc/sys/vm/drop_caches 
> 
> On the NFS client, send some data to the fd:
> 
> # ls -la
> # 
> 
> On the NFS server, check the kern log:
> 
> Aug 20 00:58:56 inotifydebug kernel: nfsd write inode=13 name=
> Aug 20 00:58:56 inotifydebug kernel: fsnotify modify inode=13 name=
> 
> The filename is lost, fsnotify does not know the filename anymore, 
> therefore inotify cannot send event about a modified file in a watched 
> directory.
> 
> End of the story.
> 
> I guess this is almost impossible to fix this fsnotify bug, this is due 
> by the fact that NFS use inode as file identifiers, so in some case this 
> is impossible to know the modified filepath, and therefore impossible to 
> match the file event to the directory watch.
> 
> Kind regards,
> Sylvain

