From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFS test suits
Date: Wed, 17 Dec 2003 09:07:05 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611302B07AE6@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AWf8q-0006cB-Kh
	for nfs@lists.sourceforge.net; Wed, 17 Dec 2003 09:07:20 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AWf8o-0003jl-3q
	for nfs@lists.sourceforge.net; Wed, 17 Dec 2003 09:07:18 -0800
To: "Amir Hermelin" <amir@montilio.com>
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

> does anyone know of any available public NFS test suits?  I'm aware of
> connectathon and SFS, are there any others?

it depends on what you want to test.

fsx is an excellent correctness test for the client,
and sometimes the server too.

iozone provides a comprehensive set of performance
microbenchmarks.

network applicance has a couple of benchmarks:  one
is called "sio" and works like iozone; the other is
called PostMark and is a good performance macrobenchmark.

lmbench has some interesting microbenchmarks that are
relevant to NFS.

fstress is good for server stressing.

there is a somewhat unmaintained test harness called
pyNFS which allows you to build custom requests
against servers using python -- this may be v4 only
at the moment.

you might also consider looking over the open group's
posix conformance tests, or IBM's linux test project,
as both may have pieces that can check the correctness
of an NFS implementation.

you might want to set up a WAN simulator between your
client and server and try some of these tests.

if you are interested in database on NFS, you might want
to acquire the TPC-C suite, although i don't believe it
is free.


-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
