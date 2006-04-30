From: Mathieu Chouquet-Stringer <ml2news@free.fr>
Subject: NFS mount point not responding with 2.6.16 on Alpha
Date: Sun, 30 Apr 2006 17:25:24 +0200
Message-ID: <20060430152524.GA17352@bigip.bigip.mine.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FaDnj-0000cA-FF
	for nfs@lists.sourceforge.net; Sun, 30 Apr 2006 08:25:35 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FaDnj-0004iM-Do
	for nfs@lists.sourceforge.net; Sun, 30 Apr 2006 08:25:35 -0700
Received: from mx1.lost-oasis.net ([212.85.153.8])
	by mail.sourceforge.net with esmtps (TLSv1:RC4-SHA:128)
	(Exim 4.44)
	id 1FaDng-0005Oq-Nr
	for nfs@lists.sourceforge.net; Sun, 30 Apr 2006 08:25:35 -0700
To: nfs@lists.sourceforge.net
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

[resending as noone replied]

	Hello,

I've been using NFS for quite some time now and starting a couple of
months ago (can't recall exactly when), I've been having issues with one
of my servers.

The box in question is an Alpha (ev56 on a LX164 mb) - bar - running
knfsd on vanilla 2.6.16 (gentoo 1.6.14 - 2006.0) with /etc/exports
looking as follow:

/somemountpoint		someclients(rw,no_root_squash,async)

The problem can manifest itself in 2 (related) ways:
- I can mount somemountpoint fine on different linux boxes (ia32 or
  sparc64 based), manually or using autofs4, but after some time
  (something like 15-20 minutes, it doesn't matter wether the mount
  point is idle or not) the mountpoint will hang (ie trying to access
  it, by using df or whatever you can think of) and in the logs, I'll
  get the following:

Apr 27 18:32:15 foo kernel: nfs: server bar not responding, still trying

- or the initial mount command will hang with an identical message as
  above

In both cases, I can 'unhang' the whole mess by trying to mount
bar:/somemountpoint on server foo.  By "trying" I meant I don't even
have to mount it, just issuing a mount command looking like this:

mount bar:/somemountpoint /somedirthatdoesntevenexist

will unfreeze the process.


When I use autofs, I get more or less the same behaviour: automount just
hangs while trying to lstat64 the local mount point.  Running the above
mount command will correct the problem.

The interesting part is that with the same kernel version, it only
happens with the alpha being the server.

Here's a typical tcpdump output from the client to the server, when the
thing is hung (df is running):

20:58:38.414238 IP foo.425107490 > bar.nfs: 92 fsstat [|nfs]
20:58:39.118267 IP foo.425107490 > bar.nfs: 92 fsstat [|nfs]
20:58:40.518379 IP foo.425107490 > bar.nfs: 92 fsstat [|nfs]
20:58:43.318715 IP foo.425107491 > bar.nfs: 92 fsstat [|nfs]
20:58:44.018787 IP foo.425107490 > bar.nfs: 92 fsstat [|nfs]
20:58:49.619500 IP foo.425107491 > bar.nfs: 92 fsstat [|nfs]
20:58:51.019655 IP foo.425107490 > bar.nfs: 92 fsstat [|nfs]
20:58:51.719753 IP foo.425107491 > bar.nfs: 92 fsstat [|nfs]
20:58:52.419828 IP foo.425107490 > bar.nfs: 92 fsstat [|nfs]
20:58:53.820003 IP foo.425107491 > bar.nfs: 92 fsstat [|nfs]
20:58:55.220205 IP foo.425107490 > bar.nfs: 92 fsstat [|nfs]
20:58:58.020527 IP foo.425107491 > bar.nfs: 92 fsstat [|nfs]


Here I issue the mount command:

20:58:59.793008 IP foo.4681 > bar.sunrpc: S 2492793988:2492793988(0) win 5840 <mss 1460,sackOK,timestamp 180392442 0,nop,wscale 4>
20:58:59.793310 IP bar.sunrpc > foo.4681: S 1555530554:1555530554(0) ack 2492793989 win 5792 <mss 1460,sackOK,timestamp 564344226 180392442,nop,wscale 2>
20:58:59.793441 IP foo.4681 > bar.sunrpc: . ack 1 win 365 <nop,nop,timestamp 180392442 564344226>
20:58:59.793911 IP foo.4681 > bar.sunrpc: P 1:45(44) ack 1 win 365 <nop,nop,timestamp 180392442 564344226>
20:58:59.794097 IP bar.sunrpc > foo.4681: . ack 45 win 1448 <nop,nop,timestamp 564344227 180392442>
20:58:59.794793 IP bar.sunrpc > foo.4681: P 1:401(400) ack 45 win 1448 <nop,nop,timestamp 564344228 180392442>
20:58:59.794858 IP foo.4681 > bar.sunrpc: . ack 401 win 432 <nop,nop,timestamp 180392442 564344228>
20:58:59.795046 IP bar.sunrpc > foo.4681: P 401:517(116) ack 45 win 1448 <nop,nop,timestamp 564344228 180392442>
20:58:59.795109 IP foo.4681 > bar.sunrpc: . ack 517 win 432 <nop,nop,timestamp 180392442 564344228>
20:58:59.795262 IP foo.4681 > bar.sunrpc: F 45:45(0) ack 517 win 432 <nop,nop,timestamp 180392442 564344228>
20:58:59.795510 IP bar.sunrpc > foo.4681: F 517:517(0) ack 46 win 1448 <nop,nop,timestamp 564344229 180392442>
20:58:59.795597 IP foo.4681 > bar.sunrpc: . ack 518 win 432 <nop,nop,timestamp 180392442 564344229>
20:58:59.795875 IP foo.898 > bar.969: UDP, length 84
20:58:59.843990 IP bar.969 > foo.898: UDP, length 56
20:58:59.845058 IP foo.900 > bar.sunrpc: UDP, length 56
20:58:59.845656 IP bar.sunrpc > foo.900: UDP, length 28
20:58:59.866673 IP bar.nfs > foo.425107490: reply ok 84 fsstat [|nfs]
20:58:59.866957 IP bar.nfs > foo.425107490: reply ok 84 fsstat [|nfs]
20:58:59.867184 IP bar.nfs > foo.425107490: reply ok 84 fsstat [|nfs]
20:58:59.867495 IP bar.nfs > foo.425107490: reply ok 84 fsstat [|nfs]
20:58:59.867742 IP bar.nfs > foo.425107490: reply ok 84 fsstat [|nfs]
20:58:59.867968 IP bar.nfs > foo.425107490: reply ok 84 fsstat [|nfs]
20:58:59.868171 IP bar.nfs > foo.425107490: reply ok 84 fsstat [|nfs]
20:58:59.868388 IP bar.nfs > foo.425107490: reply ok 84 fsstat [|nfs]
20:58:59.868608 IP bar.nfs > foo.425107490: reply ok 84 fsstat [|nfs]
20:58:59.868849 IP bar.nfs > foo.425107490: reply ok 84 fsstat [|nfs]
20:58:59.869072 IP bar.nfs > foo.425107490: reply ok 84 fsstat [|nfs]
20:58:59.869313 IP bar.nfs > foo.425107490: reply ok 84 fsstat [|nfs]
20:58:59.869538 IP bar.nfs > foo.425107490: reply ok 84 fsstat [|nfs]


And at this point everything is back to normal (well sort of)...


I've tried to pinpoint the problem but so far I've got admit I've been
quite unsucessfull (note that when it happens, all the services:
portmap, rpc, mountd, and so on are running).  So my first question
would be: where do I begin?  (more tcpdump or raising nfsd/rpc debug
level)?

Cheers,

-- 
Mathieu Chouquet-Stringer


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
