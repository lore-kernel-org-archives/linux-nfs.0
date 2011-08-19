Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail2.shareable.org ([80.68.89.115]:57532 "EHLO
	mail2.shareable.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754647Ab1HSXh6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Aug 2011 19:37:58 -0400
Date: Sat, 20 Aug 2011 00:37:56 +0100
From: Jamie Lokier <jamie@shareable.org>
To: Sylvain Rochet <gradator@gradator.net>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: PROBLEM: 2.6.35.7 to 3.0 Inotify events missing
Message-ID: <20110819233756.GI11512@jl-vm1.vm.bytemark.co.uk>
References: <20101018223540.GA20730@gradator.net>
 <20110819230344.GA24784@gradator.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110819230344.GA24784@gradator.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Sylvain Rochet wrote:
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

Oh dear, that's a security hole, if something is using inotify/dnotify
to watch and assumes that file contents (on the same machine,
i.e. server in this case) do not change if there's no event received.

It also breaks cache applications which make the same assumption.  Is
a solution to open inotify watches on every file individually?  If so
that seems quite severe.

I do quite like the idea of using it to break past fanotify security
restrictions though ;-)

Can it also be bypassed with sys_open_by_handle_at?


Possible solution:

One way to look at this as like NFS having a secret hard link to the
file, which does not show up in st_nlink.

Hard links are already a bit tricky with fsnotify and directory
watches.  You can monitor a directory, but a file in it can change
contents through another path.

However, you can track changes of hard-linked files accurately by
either putting a watch directly on all files whose st_nlink >= 2,
and/or making sure you have watches on enough distinct directories
that they contain st_nlink entries for the same file between them,
because at least one of those directories will get an event.  This is
quite practical: You watch the files directly, until such time as you
have found all its links (if you ever do), then you can remove the
direct file watches.

That gives me an idea to help with the NFS no-name watching:

It looks like when a file is referenced by inode without a path, the
problem is there's no path, so no directory inode to receive the
event?

Then this can be solved, in principle (if there's no better way), by
watching a "virtual directory" that gets all events for when the
access doesn't have a parent directory.  There needs to be some way to
watch it, and some way to get the appropriate file from the event (as
there is no real directory.  Or maybe there could be a virtual
filesystem (like /proc, /sys etc.) containing a magic directory that
receives these inode-only events, such that lookups in that directory
yield the affected file.  Exactly as if the directory contains a hard
link to every file, perhaps a text encoding of the handles passed
through sys_open_by_handle_at.

-- Jamie
