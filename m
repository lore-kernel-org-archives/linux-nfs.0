From: Chris Penney <cpenney@gmail.com>
Subject: NFS Client Performance Question
Date: Wed, 13 Jul 2005 14:30:00 -0400
Message-ID: <111aefd050713113071f0c9ce@mail.gmail.com>
Reply-To: penney@msu.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dsm0G-0007ZQ-PM
	for nfs@lists.sourceforge.net; Wed, 13 Jul 2005 11:30:40 -0700
Received: from wproxy.gmail.com ([64.233.184.201])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1Dsm0G-00088f-IQ
	for nfs@lists.sourceforge.net; Wed, 13 Jul 2005 11:30:40 -0700
Received: by wproxy.gmail.com with SMTP id i30so231807wra
        for <nfs@lists.sourceforge.net>; Wed, 13 Jul 2005 11:30:34 -0700 (PDT)
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

I have a large smp SGI Itanium box box running a 2.4.21 kernel and I'm
getting fairly bad NFS performance, esp. when doing random writes to
an unloaded NFS server.  The box is rather busy doing computation and
a lot of i/o to /tmp; however, there is little network i/o (<100
KB/s).  I use iozone with the following options to test "-c -e -i 2 -w
-s 16m" and use an unloaded Sun NFS server (same performance results
with Linux NFS servers, but they are all under load so I test with the
Sun).  I only get ~2.5MB/s using the above test.  I found an Intel box
still running a 2.4.20 kernel and it gets 15MB/s.  On a 2.6 kernel box
the rate jumps to 46MB/s (nice work).

I did some sniffing on the Sun and noticed that the problem Itanium
system was not doing async writes (snips are from the start of the
write test):

[snip]
redhat -> server NFS C WRITE3 FH=3D40E5 at 1478656 for 4096 (ASYNC)
server -> redhat NFS R WRITE3 OK 4096 (ASYNC)
redhat -> server NFS C WRITE3 FH=3D40E5 at 1179648 for 4096 (ASYNC)
[snip]
itanium -> server NFS C WRITE3 FH=3D40E5 at 4239360 for 4096 (FSYNC)
server -> server NFS R WRITE3 OK 4096 (FSYNC)
server -> server NFS C WRITE3 FH=3D40E5 at 15101952 for 4096 (FSYNC)
[snip]

The client mount options are:
   rw,nosuid,bg,hard,intr,nfsvers=3D3,tcp,rsize=3D32768,wsize=3D32768

So my question: Is the Itanium system not doing async nfs i/o because
nfract_sync has been exceeded due to local i/o to /tmp or is it
something else?  Is there anything I can do to improve NFS performance
on this box?

   Chris


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
