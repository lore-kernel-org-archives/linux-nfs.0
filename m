From: James Pearson <james-p@moving-picture.com>
Subject: Re: [bug] FC2/2.6.8.1 does not fallback to NFSv2
Date: Sat, 28 Aug 2004 17:47:47 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4130B733.7070506@moving-picture.com>
References: <20040827212244.GA57703@brandon.dvalentine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C16Me-0002Jv-72
	for nfs@lists.sourceforge.net; Sat, 28 Aug 2004 09:47:40 -0700
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C16Mc-0006Fp-G2
	for nfs@lists.sourceforge.net; Sat, 28 Aug 2004 09:47:40 -0700
To: "Brandon D. Valentine" <brandon@dvalentine.com>
In-Reply-To: <20040827212244.GA57703@brandon.dvalentine.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

It's a bug in Redhat's util-linux package - see:

https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=123416

As yet, I haven't found a fixed version available from Redhat - my 
simple workround is as follows - I guess it's OK, as this check doesn't 
seem to exist in other versions of nfsmount.c

James Pearson

*** util-linux-2.12/mount/nfsmount.c.dist       2004-07-08 
15:08:38.000000000 +0
100
--- util-linux-2.12/mount/nfsmount.c    2004-07-08 15:15:28.000000000 +0100
***************
*** 423,430 ****
--- 423,435 ----
                                 return 1;
                         memcpy(mnt_pmap, &save_mnt, sizeof(*mnt_pmap));
                 }
+
+               /* the following check breaks the automatic fall back
+                  to NFSv2 - JCP 8/7/2004 */
+ #if 0
                 if (rpc_createerr.cf_stat != RPC_PROGNOTREGISTERED)
                         break;
+ #endif
                 memcpy(nfs_pmap, &save_nfs, sizeof(*nfs_pmap));
         }
    out_bad:

Brandon D. Valentine wrote:
> [ I tried to send this yesterday without actually subscribing, but it
> has yet to make it past the list moderator.  I've given up and
> subscribed to yet another mailing list to get this bug report out. ]
> 
> We have just brought up several Fedora Core 2 systems running the latest
> 2.6.8.1 kernel revision in our NIS/NFS+autofs environment.  The FC2/2.6
> clients are refusing to mount one specific filesystem on our network.
> This filesystem is exported by a Debian/woody system running a 2.4.18
> kernel.  The kernel on this machine only supports NFSv2 exports.
> 
> When the FC2/2.6 client attempts to automount the filesystem on the 2.4
> server we observe the following in the client's syslog:
> 
>   Aug 26 18:37:08 scylla automount[5056]: >> mount to NFS server 'reef'
>   failed: server is down.
>   Aug 26 18:37:08 scylla automount[5056]: mount(nfs): nfs: mount failure
>   reef:/export/reef/httpd/ on /sb/www
>   Aug 26 18:37:08 scylla automount[5056]: failed to mount /sb/www
> 
> And the following is observed in the server's syslog:
> 
>   Aug 26 18:37:12 reef kernel: svc: unknown version (3)
> 
> At this point the client gives up with the following error:
> 
>   [root@scylla root]# ls /sb/www
>   ls: /sb/www: No such file or directory
> 
> None of our other Linux systems running 2.4 kernels have any trouble
> mounting that filesystem.  They all automount it using NFSv2 as
> expected.  All of our 2.4 systems also correctly mount using NFSv3 from
> systems that support it.
> 
> Autofs is configured on the FC2 systems to permit NFSv2 mounts as shown
> by the minproto option below:
> 
>   [root@scylla root]# mount | grep automount
>   automount(pid1665) on /home type autofs (rw,fd=4,pgrp=1665,minproto=2,maxproto=4)
>   automount(pid1695) on /sb type autofs (rw,fd=4,pgrp=1695,minproto=2,maxproto=4)
>   automount(pid1739) on /scratch type autofs (rw,fd=4,pgrp=1739,minproto=2,maxproto=4)
> 
> The 2.6.8.1 kernel is configured with the following options:
> 
>   [root@scylla root]# grep -i nfs /usr/src/linux/.config
>   CONFIG_NFS_FS=y
>   CONFIG_NFS_V3=y
>   # CONFIG_NFS_V4 is not set
>   # CONFIG_NFS_DIRECTIO is not set
>   CONFIG_NFSD=y
>   CONFIG_NFSD_V3=y
>   # CONFIG_NFSD_V4 is not set
>   CONFIG_NFSD_TCP=y
> 
> I am able to manually mount this filesystem, but only if I explicitly
> add the vers=2 option to the mount command:
> 
>   [root@scylla root]# mount -t nfs reef:/export/reef/httpd/ /mnt/temp
>   mount to NFS server 'reef' failed: server is down.
>   [root@scylla root]# mount -t nfs -o vers=2 reef:/export/reef/httpd/ /mnt/temp
>   [root@scylla root]#
> 
> Given the fact that the mount fails manually until vers=2 is specified I
> am inclined to believe this is a kernel NFS bug, not an autofs or mount
> bug.
> 
> I would be glad to gather any additional information that might be
> necessary to determine the cause of this behavior.  Can anyone reproduce
> this or have advice on how I might fix it?
> 
> Thanks,
> 
> Brandon D. Valentine


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
