From: "Magnus Naeslund\(f\)" <mag@fbab.net>
Subject: Re: App hanging at NFS failure
Date: Tue, 17 Sep 2002 20:05:41 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <003b01c25e74$d5d5a180$f80c0a0a@mnd>
References: <6440EA1A6AA1D5118C6900902745938E07D54E62@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail2.fbab.net ([195.54.134.228])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17rMj9-0007iy-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Sep 2002 11:05:35 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

Lever, Charles <Charles.Lever@netapp.com> wrote:
>> If i have a program that uses sendfile to send a file to the
>> network from an NFS server (mount options:
>> rw,noatime,hard,intr,rsize=3D8192,wsize=3D8192) and reboot the
>> NFS server the program is still hung when the NFS server is
>> online again.
>=20
> how long does it take to restart your NFS server?  how long do
> you wait before deciding your application is hung?  oh, and
> of course, which distribution and kernel version?
>=20

Oh, i forgot, the server is "fet1a.our.net 2.4.18-10custom #2 SMP Tue =
Aug 27 03:27:31 CEST 2002 i686 unknown" an dual athlon running RedHat =
7.3, no patches, redhat supplied kernel.

The downtime is the time it takes to reboot the nfs server machine:

Sep 16 13:45:06 gserver1 kernel: nfs: server fet1a.our.net is not =
responding=20
Sep 16 13:45:21 gserver1 kernel: nfs: server fet1a.our.net OK=20
Sep 16 13:46:22 gserver1 kernel: nfs: server fet1a.our.net is not =
responding=20
Sep 16 13:47:00 gserver1 kernel: nfs: server fet1a.our.net still not =
responding=20
Sep 16 13:47:49 gserver1 kernel: nfs: server fet1a.our.net still not =
responding=20
Sep 16 13:48:31 gserver1 kernel: nfs: server fet1a.our.net still not =
responding=20
Sep 16 13:48:46 gserver1 kernel: nfs: server fet1a.our.net OK=20


>> When i try to strace it, it starts to run again, and works as
>> usual, the same if i debug it with gdb.
>=20
> try tracing it with "echo 3 > /proc/sys/sunrpc/rpc_debug"
> this produces a ton of kernel log output, but may show why
> the NFS client has stopped servicing application requests.
> use "echo 0 > /proc/sys/sunrpc/rpc_debug"

As soon as i can get a test machine up and running i'll try that.

The thing is that only the processes that was sendfiling from the nfs =
partition at the time of reboot hung, after the server is up again, the =
other processes work just fine (the process is started in an inetd =
fashion (using djb's daemontools)).

So everything is fine except that the "old" processes are hung, and =
needs to me kill -CONT or something to snap out of it.

The nfs clients own tcp clients times out during the downtime, if that =
could have anything to do with it? Kinda if the tcpsocket goes crazy =
because it's stuck in NFS during the disconnect or something?

Magnus



-------------------------------------------------------
This SF.NET email is sponsored by: AMD - Your access to the experts
on Hammer Technology! Open Source & Linux Developers, register now
for the AMD Developer Symposium. Code: EX8664
http://www.developwithamd.com/developerlab
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
