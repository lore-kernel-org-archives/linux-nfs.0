From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: NFS mount problem (2000 NFS filesystems) of linux clients
 to a solaris server
Date: Thu, 08 Mar 2007 08:08:10 -0500
Message-ID: <EXNANE01FRaqbC8wSA10000007f@exnane01.hq.netapp.com>
References: <45F004BD.1070500@biochem.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS@lists.sourceforge.net
To: Bernhard Busch <bbusch@biochem.mpg.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
In-Reply-To: <45F004BD.1070500@biochem.mpg.de>
References: <45F004BD.1070500@biochem.mpg.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

At 07:42 AM 3/8/2007, Bernhard Busch wrote:
>It is possible to export these 2000 filesystems on the server (sun solaris)
>and  to  mount these 2000 nfs filesystem on sgi and solaris
>clients without any problems.
>
>
>On Linux Clients (SLES10, Suse10.2)  i get 
>error messages like the following ones:
>
>nfs bindresvport: Address already in use
>nfs bindresvport: Address already in use
>nfs bindresvport: Address already in use
>mount: solaris10-02:/fs/DISK/disk1998: can't read superblock
>mount: solaris10-02:/fs/DISK/disk1999: can't read superblock
>mount: solaris10-02:/fs/DISK/disk2000: can't read superblock

You need to increase the number of ports available on the Linux NFS
client.

echo 65535 >/proc/sys/sunrpc/max_resvport

This will raise it to the maximum, you could use smaller values but
because you are creating so many mounts, that would quite possibly
start to collide with other reserved ports.

In fact, you might want to set /proc/sys/sunrpc/min_resvport to
something large (32768), also in order to avoid collisions. However
that in turn might require reconfiguring some of your NFS servers to
accept "nonprivileged" ports (Linux server export option "insecure",
others see documentation).

Tom.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
