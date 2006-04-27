From: "Michael Lackner" <thrawn@xin.at>
Subject: NFS over a Win2k Server NAT Router with "DMZ": nfs: server not responding, still trying
Date: Thu, 27 Apr 2006 18:39:16 +0200
Message-ID: <005401c66a19$2a6f6d30$0200a8c0@novastorm>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FZ9X9-0005F6-2O
	for nfs@lists.sourceforge.net; Thu, 27 Apr 2006 09:40:03 -0700
Received: from 83-64-254-60.bruck-mur.xdsl-line.inode.at ([83.64.254.60] helo=xin.at)
	by mail.sourceforge.net with esmtps (TLSv1:RC4-MD5:128)
	(Exim 4.44)
	id 1FZ9X7-0000Fy-6I
	for nfs@lists.sourceforge.net; Thu, 27 Apr 2006 09:40:03 -0700
Received: from novastorm by xin.at
	(MDaemon.PRO.v8.1.3.R)
	with ESMTP id md50000005492.msg
	for <nfs@lists.sourceforge.net>; Thu, 27 Apr 2006 18:39:23 +0200
To: <nfs@lists.sourceforge.net>
Sender: nfs-admin@lists.sourceforge.net
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

Hello!

Despite being new, i already have an interesting problem to solve (or i at least think so).

I work at a university, and we decided to place a router/firewall before 25 WinXP/Linux
computers used by students. The router would also serve as software distribution server
(MS IntelliMirror), so we decided to use MS Windows 2000 Server.

The server is routing with RRAS, and has 25 public IPs reserved and mapped to the
private IPs of those 25 machines, so that a few people can directly connect to those
PCs (in the future, the firewall on the router will decide who to let through and who
to block). For outgoing connections from those 25 machines to the outside world,
standard RRAS NAT is used.

Everything works so far, clients can connect to the outside world, and the Win2k Server
"DMZ" configuration works fine in letting our people through into the private pool using 
SSH. They just connect to the external IP (like 193.170.71.233) and are then routed 
to the corresponding private IP (like 10.20.15.233). 

And here comes the problem:

Users' home directories are mounted via AutoFS/NFS at login time. Both users and 
AutoFS information are stored in an OpenLDAP database. The NFS server runs on the 
same machine as the LDAP server does, let's call it the "fileserver". This machine is a
RedHat 9 Linux box with the stock NFS and OpenLDAP servers, Kernel 2.4.20. NFS
is v2 and v3, UDP only. rpcinfo -p <ip of fileserver> shows the services correctly,
no matter if i connect from the same network segment the NFS server is in, or from
my private network over the NAT router. OpenLDAP replies ok from within the private 
network too (tested with "id", reading user data out of the LDAP database and with 
"ldapsearch").

Now, i can mount directories from the fileserver, and i can cd into them. I can even cd
into subdirectories of a mounted directory! However, as soon as i try to "ls"/"dir" or
open a file, it's stuck. The last thing the NAT router shows is an outgoing translated
connection to the NFS server, port 2049. rpcinfo shows, that "nfs" is running on that 
port on the fileserver. But nfs seems to not respond to that translated connection.

The server is accessible from within its own network segment, totally ok, NFS mounts work. 
However, the described situation occurs, as soon as i try to mount and read NFS shares from 
within my "private" pool. All 25 machines show the same behavior.

dmesg and /var/log/messages say:
nfs: server <ip> not responding, still trying

Now you might think it's just the Win2000 Server NAT doing something wrong, so i 
set up another NFS server quickly, lets call him "testserver". This time i used a more modern
Fedora Core 4 distribution, NFS is v2 and v3, UDP and TCP. This server is standing in
the outside world too.

I tried to mount an exported directory on the testserver from within my private network
with the following parameters:
nfsver=2,udp
nfsver=3,udp
nfsver=2,tcp
nfsver=3,tcp

Works every time! I also tried those parameters on the fileserver. TCP of course didn't work
at all, wouldn't let me mount anything, but with all the other parameters, i still got stuck when
trying to ls within a mounted directory from the fileserver.

So, my best guest would have been to just update NFS on the fileserver, because a newer
version seems to understand and correctly reply to my NAT'ed packages, that fly over 
the Win2000 Server Router.

But how can i update the server, without recompiling the kernel? As far as i understand it,
the NFS support is compiled directly into the kernel, and there are no binary kernel updates
for RedHat 9 anymore. Upgrading the whole machine to a newer distribution is also not
acceptable, as this would mean breaking the license servers currently running on that machine
as well as our backup solution.

To sum this up:

1.) Private IP Pool: 10.20.15.0/16, can connect to the internet (http, ftp etc.) through Win2k
router.
2.) Public IP Pool (changed for security reasons, but equivalent): 193.170.71.0/24
3.) Win2000 NAT Router with Interfaces 10.20.15.1/16 and 193.170.71.229/24
4.) Win2000 NAT Router reserves 25 addresses (193.170.71.230-193.170.71.254)
and maps those to 10.20.15.2 - 10.20.15.26, works for incoming SSH and ping, etc.
5.) not-working fileserver with NFS/LDAP is 193.179.71.208.
6.) working testserver with newer Linux and NFS is 193.171.71.207.
7.) For testing purposes, all firewalls and SELinux configurations have been disabled
on all machines!
/etc/exports and /etc/hosts.allow as well as /etc/hosts.deny have been checked on the 
fileserver to ensure it doesn't just drop my connections. 
8.) Even serving a directory within the private IP Pool via NFS and mounting it from
a machine outside WORKS...  (tested this just because i didn't know what else to do anymore)

Is there a way to better analyze / fix this, without replacing the Microsoft router and without
having to recompile the whole kernel (+additional nfs software?) on the fileserver or having
to completely reinstall the fileserver?

What i really do not understand is, why the mounting works, why i can even cd in every
subdirectory of the mounted nfs directory on the fileserver, but i can't read files or dirlistings.

I'm surely no NFS professional, so help for better understanding and probably solving this
problem would be greatly appreciated! Frankly, i don't dare to touch the fileserver too much,
as this is one hell of a critical machine...

Thanks in advance and sorry for writing that much.

Best Regards
Michael Lackner
University of Leoben
Chair for Information Technology, IT Administration



-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
