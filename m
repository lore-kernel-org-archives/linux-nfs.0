From: Jeffrey Layton <jtlayton@poochiereds.net>
Subject: Re: Poor NFS performance, kernel 2.6.6.
Date: Wed, 02 Jun 2004 08:33:53 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1086179633.3325.0.camel@tesla.mmt.bellhowell.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVUwO-0007nI-FM
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 05:33:56 -0700
Received: from rdu26-93-067.nc.rr.com ([66.26.93.67] helo=salusa.poochiereds.net)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVUwO-0008Kc-3N
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 05:33:56 -0700
Received: from localhost (localhost [127.0.0.1])
	by salusa.poochiereds.net (Postfix) with ESMTP id 996C8CAE0
	for <nfs@lists.sourceforge.net>; Wed,  2 Jun 2004 08:33:45 -0400 (EDT)
Received: from salusa.poochiereds.net ([127.0.0.1])
	by localhost (salusa [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 03814-09 for <nfs@lists.sourceforge.net>;
	Wed, 2 Jun 2004 08:33:45 -0400 (EDT)
Received: from localhost (salusa.poochiereds.net [192.168.1.2])
	by salusa.poochiereds.net (Postfix) with ESMTP id 55BE471F1
	for <nfs@lists.sourceforge.net>; Wed,  2 Jun 2004 08:33:45 -0400 (EDT)
To: nfs@lists.sourceforge.net
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

I haven't been following this thread closely, but figured I'd chime in
with my own experience with this. Here's a rather unscientific test,
dd'ing to a file on an NFS-mounted filesystem. Mount options are:

udp,soft,intr,nfsvers=3

(I'm using UDP as I'm trying to set up a HA-NFS server, and the clients
seem to recover much faster when using UDP as a transport).

With a 2.4 kernel server:

% time dd if=/dev/zero of=./testfile bs=100M count=1
1+0 records in
1+0 records out
104857600 bytes transferred in 11.806235 seconds (8881544 bytes/sec)
dd if=/dev/zero of=./testfile bs=100M count=1  0.00s user 0.28s system
2% cpu 12.147 total

With a 2.6 kernel server:

% time dd if=/dev/zero of=./testfile bs=100M count=1
1+0 records in
1+0 records out
104857600 bytes transferred in 66.997572 seconds (1565096 bytes/sec)
dd if=/dev/zero of=./testfile bs=100M count=1  0.00s user 0.29s system
0% cpu 1:07.06 total


The machines are different hardware, but local write performance is
pretty comparable (in fact the 2.6 box is a faster machine, and is
currently less utilized than the 2.4 kernel machine). Both are using
reiserfs as the underlying filesystem.

Write performance in this cursory test was 10x worse! Clearly, there's
some sort of problem with NFS on 2.6. I'll be happy to send in what info
I can. My 2.4 machine is currently a production box, but I can run an
instrumented kernel, etc. on the 2.6 box in the near future if anyone
here can guide me on what I can do to help.

-- Jeff




-------------------------------------------------------
This SF.Net email is sponsored by the new InstallShield X.
