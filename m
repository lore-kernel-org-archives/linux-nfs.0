Return-Path: <nfsv4-bounces@linux-nfs.org>
Message-Id: <7123090D-5BB9-4CF5-A024-56345DD8136F@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Guillaume Rousse <guillaume.rousse@inria.fr>
In-Reply-To: <4B530EFF.9000205@inria.fr>
Subject: Re: unmount -l does not send unmount request to the server
Date: Tue, 19 Jan 2010 11:37:43 -0500
References: <4B530EFF.9000205@inria.fr>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"; Format="flowed"; DelSp="yes"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

Cc'ing NFSv3 mailing list.

On Jan 17, 2010, at 8:22 AM, Guillaume Rousse wrote:

> Hello list.
>
> A mandriva user report than unmount filesystem at shutdown is broken
> since the move of {mount,unmount}.nfs commands from coreutils to
> nfs-utils, some times ago:
> https://qa.mandriva.com/show_bug.cgi?id=36490
>
> It seems to be caused by the use of -l option in initscripts, which
> apparently don't send an umount request to the server anymore. A  
> simple
> test is enough to confirm it:
>
> When using 'mount.nfs server:/dir dir && umount.nfs dir' on the  
> client,
> the server logs:
> Jan 17 14:01:12  mountd[18714]: authenticated mount request from
> 192.168.0.1:840 for /home (/home)
> Jan 17 14:01:12  mountd[18714]: authenticated unmount request from
> 192.168.0.1:1012 for /home (/home)
>
> When using 'mount.nfs server:/dir dir && umount.nfs dir -l' on the
> client, the server logs:
> Jan 17 14:09:17  mountd[18714]: authenticated mount request from
> 192.168.0.1:955 for /home (/home)
>
> The filesystem is umounted client-side, but the server still thinks he
> is connected:
> [root@oberkampf Desktop]# showmount
> Hosts on oberkampf:
> 192.168.0.1
>
> client uses nfs-utils 1.2.0.
>
> Reading the code in nfsumount.c, as suggested by comment #11
> (https://qa.mandriva.com/show_bug.cgi?id=36490#c11) seems to imply  
> this
> is on purpose:
>    if (mc) {
>        if (!lazy && strcmp(mc->m.mnt_type, "nfs4") != 0)
>            /* We ignore the error from nfs_umount23.
>             * If the actual umount succeeds (in del_mtab),
>             * we don't want to signal an error, as that
>             * could cause /sbin/mount to retry!
>             */
>            nfs_umount23(mc->m.mnt_fsname, mc->m.mnt_opts);
>        ret = del_mtab(mc->m.mnt_fsname, mc->m.mnt_dir) ?: ret;
>    } else if (*spec != '/') {
>        if (!lazy)
>            ret = nfs_umount23(spec, "tcp,v3");
>
> The description of this option seems to imply than he filesystem is
> marked as unmounted right now in mtab, and than he is actually  
> umounted
> properly as soon as possible. This doesn't says anything about the
> server, tough, and I doesn't see anything in the code dealing with  
> this
> 'as soon as possible' event anyway...

The init scripts use "-l" because they don't want a hang at shutdown.   
A hang might occur if the server is unreachable.

A UMNT is usually sent when the client knows it won't be using that  
export any longer.

As far as I understand it, "-l" means the kernel will do the local  
detach from the system's file name space whenever there are no more  
users (ie entirely asynchronously).  I don't think umount2(MNT_DETACH)  
indicates whether the kernel was able to completely unmount that file  
system by the time the call returns, so there's perhaps no way for  
umount.nfs to know whether it should send the UMNT request.  If the  
server is slow or unresponsive, that file system won't be unmounted  
until long after the umount.nfs command has exited.

This shouldn't be much of a big deal, since the server's rmtab is  
"ornamental" according to the man page.  No one should rely on it  
being accurate.

A possible way to fix this is to have the kernel send the UMNT.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
