From: "Steve Wolfe" <nw@codon.com>
Subject: Perennial question, unable to mount
Date: Tue, 18 Feb 2003 12:12:19 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <001001c2d781$aa6fc580$88693fd1@WEASEL>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from local.iboats.com ([209.63.105.131])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lD5w-0000yc-00
	for <nfs@lists.sourceforge.net>; Tue, 18 Feb 2003 11:07:56 -0800
To: <nfs@lists.sourceforge.net>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


  I have a number of clients that all connect to a central NFS server.
Recently, one client lost the ability to mount NFS volumes, and I've been
pulling my hairs out trying to make it work.

  All of these servers use fairly old versions of NFS utils and the like.
I've tried upgrading, but invariably, upgrading one machine will break its
ability to mount NFS volumes, or if I upgrade the file server, the clients
can't mount.  I'd love to simply upgrade all of them at the same time, but
simply don't have the opportunity, I can't take them all offline at once,
and I can't risk an extended outtage while I fiddle with different
versions.  If there's a way I can upgrade one at a time, I'd love to hear
about it.  For now, on to the pressing problem:

  The server in question has nfsutils 0.1.6, and the client has 0.3.3.
Other clients also have 0.3.3.  Server and clients both us the 2.4.19
kernel, with the o(1) scheduler.

   When I attempt to mount a volume from this *particular* client, after a
long pause, I get "mount;  RPC:  Timed out".  rpcinfo -p shows the
portmapper, status, and mountd running on both client and server.  The
server also has "nfs" and "nlockmgr" in the output.  I ran tcpdump on the
client while I tried the mount, and here's the interesting bit:
Interspersed with the ~200 packets that go back and forth without any
problem, I get lines like these:

11:52:25.044770 eth1 > c1.748 > fs.854: udp 104 (DF)
11:52:25.044967 eth1 < fs > cgi1-fs: icmp: fs udp port 854 unreachable
[tos 0xc0]
11:52:28.055411 eth1 > c1.748 > fs.854: udp 104 (DF)
11:52:28.055612 eth1 < fs > cgi1-fs: icmp: fs udp port 854 unreachable
[tos 0xc0]
11:52:31.066073 eth1 > c1.748 > fs.854: udp 104 (DF)
11:52:31.066332 eth1 < fs > cgi1-fs: icmp: fs udp port 854 unreachable
[tos 0xc0]
11:52:34.076729 eth1 > c1.748 > fs.854: udp 104 (DF)
11:52:34.076997 eth1 < fs > cgi1-fs: icmp: fs udp port 854 unreachable
[tos 0xc0]

  On the NFS server, rpcinfo -p shows that mountd is, in fact, listening
on port 854/udp.  All of the clients are on the same private network,
using the same physical layer to get to the file server.  I can't think of
any reason why the client would not be able to reach the file server on
that port - any suggestions?

steve



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
