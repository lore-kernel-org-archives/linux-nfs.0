From: "Jeff McNeil" <jeff-ugcqE8b+Z2XR7s880joybQ@public.gmane.org>
Subject: Re: Negative dentry hits not revalidating correctly?
Date: Wed, 28 May 2008 15:04:10 -0400
Message-ID: <82d28c40805281204r7631df9ey7c0162955d4eb8d8@mail.gmail.com>
References: <82d28c40805281153m2eec3c83ide3abae0edb84808@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.239]:35259 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752457AbYE1TEL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 May 2008 15:04:11 -0400
Received: by rv-out-0506.google.com with SMTP id l9so3660316rvb.1
        for <linux-nfs@vger.kernel.org>; Wed, 28 May 2008 12:04:10 -0700 (PDT)
In-Reply-To: <82d28c40805281153m2eec3c83ide3abae0edb84808-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Just for clarity - I had the steps a bit out of order - I can wait an
10 minutes after creating the file on the second node and it simply
does not show up on any of the other nodes.

On Wed, May 28, 2008 at 2:53 PM, Jeff McNeil <jeff-ugcqE8b+Z2XR7s880joybQ@public.gmane.org> wrote:
> Hi NFS list!
>
> I've been dealing with a bit of a problem over the past few days that
> I can't seem to get through. First, a bit of information about my
> environment.  We're using a BlueArc Titan NAS cluster in concert with
> NFS v3 over TCP. The Linux hosts are all running a fairly recent
> update of RHES5, uname -a tells me ' 2.6.18-53.1.13.el5PAE.'   My
> apologies for the patched-up Red Hat kernel as opposed to a stock
> build.
>
> Mount options are as follows:
>
> lnh-nfs01:/lthfs01 on /home/cluster1 type nfs
> (rw,nfsvers=3,proto=tcp,hard,intr,wsize=32768,rsize=32768,addr=10.2.25.19)
>
> The environment is pretty straightforward.  It's generally just a
> run-of-the-mill H/A web cluster.  We're utilizing bind mounts in a few
> situations, but the problem I'm having manifests itself on machines
> both with and without bind mounts.
>
> In summary, it appears that once a file has a negative dcache entry,
> it is never revalidated correctly without some sort of intervention.
> I've been able to mitigate the problem either by dropping caches more
> often than I'd like via /proc/sys/vm/drop_caches, or by stepping into
> the parent directory of the 'missing' file and running an 'ls.'  It
> appears that the 'ls' triggers an invalidation of the parent directory
> (which is what we're looking for initially).
>
> To trigger the issue:
>
> 1. Stat a file that we know is non-existant. This populates the dentry
> cache with a negative entry.
>
> [root@lnh-util ~]# ssh root@lnh-www1a-mgmt
> "stat /home/cluster1/data/f/f/nfsuser01/test_nofile"
> stat: cannot stat `/home/cluster1/data/f/f/nfsuser01/test_nofile': No
> such file or directory
>
> 2. Create that file on a different server, this will also update the
> mtime on that parent directory, so the NFS validation code on the dentry
> hit ought to catch that.
>
> [root@lnh-util ~]# ssh root@lnh-sshftp1a-mgmt
> "touch /home/cluster1/data/f/f/nfsuser01/test_nofile"
>
> 3. Try and stat the file again. Still broken.
>
> [root@lnh-util ~]# ssh root@lnh-www1a-mgmt
> "stat /home/cluster1/data/f/f/nfsuser01/test_nofile"
> stat: cannot stat `/home/cluster1/data/f/f/nfsuser01/test_nofile': No
> such file or directory
>
> 4. Wait at least 60 seconds, just to rule out attribute cache data
> (though from reading
> the code, it appears that the parent directory is revalidated
> regardless in nfs_check_verifier). We're
> using defaults.
>
> 5. Read the parent directory.
>
> [root@lnh-util ~]# ssh root@lnh-www1a-mgmt
> "ls /home/cluster1/data/f/f/nfsuser01/ | wc -l"
> 16
>
> 6. And now the missing file is present.
>
> [root@lnh-util ~]# ssh root@lnh-www1a-mgmt
> "stat /home/cluster1/data/f/f/nfsuser01/test_nofile"
>  File: `/home/cluster1/data/f/f/nfsuser01/test_nofile'
>  Size: 0               Blocks: 0          IO Block: 4096   regular
> empty file
> Device: 15h/21d Inode: 4046108346  Links: 1
> Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
> Access: 2008-05-28 10:07:28.963000000 -0400
> Modify: 2008-05-28 10:07:28.963000000 -0400
> Change: 2008-05-28 10:07:28.963000000 -0400
> [root@lnh-util ~]#
>
> The negative file entry continuously stays present.  This is true even
> when a stat of the parent directory shows that the cached attributes
> have timed out and we've updated mtime data.
>
> Thoughts?
>
> Jeff
>
