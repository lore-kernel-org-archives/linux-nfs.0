From: James Pearson <james-p@moving-picture.com>
Subject: Re: NFS problems across reboot
Date: Fri, 05 Apr 2002 10:12:24 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CAD6A78.4205CD61@moving-picture.com>
References: <3CACA93C.5010304@blue-labs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16tPqp-000308-00
	for <nfs@lists.sourceforge.net>; Fri, 05 Apr 2002 01:17:43 -0800
To: David Ford <david+cert@blue-labs.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Can't offer any solutions, but I've had the same problem - (see
http://marc.theaimsgroup.com/?l=linux-nfs&m=101610950230938&w=2 )

In my case, one particular application (accessing files via NFS on the
server at the time) was causing the server machine to crash, when the
server rebooted, Linux clients got "Permission denied" problems on the
mount points from the server (IRIX clients reported "I/O Error" on the
same mount points).

I thought I had fixed the problem by using a newer kernel on the server
- but all this fixed was the application in question crashing the
machine ... I still see the "Permission denied" problem from time to
time (df reports a similar output to yours as well) - however I don't
see it every time a 'server' reboots - most of our Linux workstations
NFS export local disks - which can be automounted by other workstations
- the workstations tend to get rebooted 'fairly' frequently.

The workaround is to umount/mount ...

I'm using kernels 2.4.7 and 2.4.14 (both with XFS).

It doesn't seem to be a Linux NFS client problem - as I mentioned above,
SGI IRIX clients have a similar problem if the Linux server
crashes/reboots.

James Pearson

David Ford wrote:
> 
> After rebooting my NFS server, the clients can no longer access the mounts.
> 
> A trimmed df shows:
> 
> james:/home/james            0         1         0   0% /home/james
> james:/home/hnc              0         1         0   0% /home/hnc
> 
> # su - xyz
> su: warning: cannot change directory to /home/james/x/xyz: Permission denied
> bash: /home/james/x/xyz/.bash_profile: Permission denied
> 
> However:
> 
> # rpcinfo -p james
>    program vers proto   port
>     100000    2   tcp    111  portmapper
>     100000    2   udp    111  portmapper
>     100005    1   udp  10000  mountd
>     100005    1   tcp  10000  mountd
>     100005    2   udp  10000  mountd
>     100005    2   tcp  10000  mountd
>     100005    3   udp  10000  mountd
>     100005    3   tcp  10000  mountd
>     100003    2   udp   2049  nfs
>     100003    3   udp   2049  nfs
>     100021    1   udp  10001  nlockmgr
>     100021    3   udp  10001  nlockmgr
>     100021    4   udp  10001  nlockmgr
>     100024    1   udp  10002  status
>     100024    1   tcp  10001  status
> 
> # umount /home/hnc
> # mount /home/hnc
> 
> And the hnc mount is fine again.  After repeating with /home/james, that
> mount is also fine.
> 
> Why do I need to umount and remount?  This is pretty brutal when I need
> to shutdown services so the mounts aren't in use.
> 
> These are 2.4.18+ kernels with nfs utils from about a month ago.
> 
> David
> 
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
