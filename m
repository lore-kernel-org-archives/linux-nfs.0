From: David Ford <david+cert@blue-labs.org>
Subject: Re: NFS problems across reboot
Date: Sat, 06 Apr 2002 23:43:56 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CAFCE8C.5030300@blue-labs.org>
References: <3CACA93C.5010304@blue-labs.org> <3CAD6A78.4205CD61@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: James Pearson <james-p@moving-picture.com>
Received: from 60.54.252.64.snet.net
	([64.252.54.60] helo=hotmale.boyland.org ident=kaliuser)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 16u4Ub-0000nO-00
	for <nfs@lists.sourceforge.net>; Sat, 06 Apr 2002 20:41:29 -0800
To: nfs@lists.sourceforge.net
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

Well, I'm an all Linux shop here, here are a few points to consider, 
Trond, please help us out.

a) All machines are Linux
b) this is 100% repeatable
c) this is entirely unacceptable, every user (/home is mounted) has to 
log out of their machine in order to remount, daemons need shut down.

Here's the scoop:

a) Linux 2.4.18-pre6 on one nfs server, 2.4.19-pre6 on the other
b) 2.4.18-pre7 through 2.4.19-pre6 on clients
c) mount options are all like: defaults,rsize=8192,wsize=8192
d) programs run/ning, portmap, kmountd, knfsd 5, lockd, and statd.
e) no firewall rules, /etc/exports is setup using individual IPs since 
the friggen system can't deal with ranges or hostnames properly, 
"Hostname is the same as "hostname" in DNS land, it should be in NFS 
land as well. exports is like: /path 1.2.3.4(rw,no_root_squash).
f) hosts.allow is basically *:all

When the server reboots (cleanly), the clients get the following, from 
rebooting to running:
nfs: server james not responding, still trying
nfs: server james not responding, still trying
nfs: server james OK
nfs: server james OK
nfs_statfs: statfs error = 13
nfs_statfs: statfs error = 13
nfs_statfs: statfs error = 13
<repeats until client is able to remount>

Basically, it's a totally simple NFS setup, but it's unusable in the 
event of a server restart because any daemon or user that has files open 
on that mount has to exit, sometimes not cleanly, and restart.  It's 
really a killer.

If this isn't fixable, can anyone recommend another network filesystem 
that has user ids, symlinks, and unix style permissions?  smb looked all 
great and dandy until I realized that symlinks don't exist and file 
permissions are pretty wacky.

Thanks,
David

James Pearson wrote:

>Can't offer any solutions, but I've had the same problem - (see
>http://marc.theaimsgroup.com/?l=linux-nfs&m=101610950230938&w=2 )
>
>In my case, one particular application (accessing files via NFS on the
>server at the time) was causing the server machine to crash, when the
>server rebooted, Linux clients got "Permission denied" problems on the
>mount points from the server (IRIX clients reported "I/O Error" on the
>same mount points).
>
>I thought I had fixed the problem by using a newer kernel on the server
>- but all this fixed was the application in question crashing the
>machine ... I still see the "Permission denied" problem from time to
>time (df reports a similar output to yours as well) - however I don't
>see it every time a 'server' reboots - most of our Linux workstations
>NFS export local disks - which can be automounted by other workstations
>- the workstations tend to get rebooted 'fairly' frequently.
>
>The workaround is to umount/mount ...
>
>I'm using kernels 2.4.7 and 2.4.14 (both with XFS).
>
>It doesn't seem to be a Linux NFS client problem - as I mentioned above,
>SGI IRIX clients have a similar problem if the Linux server
>crashes/reboots.
>
>James Pearson
>
>David Ford wrote:
>
>>After rebooting my NFS server, the clients can no longer access the mounts.
>>
>>A trimmed df shows:
>>
>>james:/home/james            0         1         0   0% /home/james
>>james:/home/hnc              0         1         0   0% /home/hnc
>>
>># su - xyz
>>su: warning: cannot change directory to /home/james/x/xyz: Permission denied
>>bash: /home/james/x/xyz/.bash_profile: Permission denied
>>
>>However:
>>
>># rpcinfo -p james
>>   program vers proto   port
>>    100000    2   tcp    111  portmapper
>>    100000    2   udp    111  portmapper
>>    100005    1   udp  10000  mountd
>>    100005    1   tcp  10000  mountd
>>    100005    2   udp  10000  mountd
>>    100005    2   tcp  10000  mountd
>>    100005    3   udp  10000  mountd
>>    100005    3   tcp  10000  mountd
>>    100003    2   udp   2049  nfs
>>    100003    3   udp   2049  nfs
>>    100021    1   udp  10001  nlockmgr
>>    100021    3   udp  10001  nlockmgr
>>    100021    4   udp  10001  nlockmgr
>>    100024    1   udp  10002  status
>>    100024    1   tcp  10001  status
>>
>># umount /home/hnc
>># mount /home/hnc
>>
>>And the hnc mount is fine again.  After repeating with /home/james, that
>>mount is also fine.
>>
>>Why do I need to umount and remount?  This is pretty brutal when I need
>>to shutdown services so the mounts aren't in use.
>>
>>These are 2.4.18+ kernels with nfs utils from about a month ago.
>>
>>David
>>
>>_______________________________________________
>>NFS maillist  -  NFS@lists.sourceforge.net
>>https://lists.sourceforge.net/lists/listinfo/nfs
>>
>
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs
>



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
