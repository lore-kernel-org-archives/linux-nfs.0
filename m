From: Marc Schmitt <mschmitt@inf.ethz.ch>
Subject: Linux Client -> Solaris Server
Date: Wed, 02 Jun 2004 16:38:23 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40BDE65F.1000009@inf.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVWpx-0008W7-Je
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 07:35:25 -0700
Received: from tri-e2k.ethz.ch ([129.132.112.23])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BVWpx-0007W4-6H
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 07:35:25 -0700
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

Hi all,

I'm looking for hints on how to improve the performance of Linux clients 
(RHEL 3.0, 2.4.21-15.EL, 100Mb NIC) talking to a Solaris server (ES250, 
SunOS 5.9 Generic_112233-11 sun4u sparc, 100Mb NIC). What I currently 
get from my testing (dd if=/dev/zero of=zero.txt bs=2048 count=1000000) 
is between 2 and 2.5 MB/s. I upped the rsize/wsize to 32768 (according 
to http://nfs.sourceforge.net/nfs-howto/interop.html#SOLARIS) which did 
not help, the result was actually worse than not specifying any mount 
options at all. Running the dd test locally on the Sun returns a 
throughput of 14MB/s (SW RAID 5 on A1000). Iperf gives a decent 85Mb/s 
throughput between the server and a client, I think it's safe to say 
that the network layer is ok. I did the test using -o 
tcp,nfsvers=3,rsize=32768,wsize=32768, too, it made no difference at all.

I hope to at least double the performance I currently measure. Does that 
mean I have to get rid of the Sun...?

Any pointers are welcome, thanks.

Greetings,
	Marc





-------------------------------------------------------
This SF.Net email is sponsored by the new InstallShield X.
