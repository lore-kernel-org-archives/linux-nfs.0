From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: NFS over TCP test results from bakerg3@yahoo
Date: Wed, 23 Apr 2003 13:42:30 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D5555A@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 198R4g-0005Db-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Apr 2003 13:42:38 -0700
To: <greg@bakers.org>, <bakerg3@yahoo.com>
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

comments below.

> ANALYSIS and CONCLUSION
>=20
> Linux tcp-nfs is not ready for production in our large
> scale distributed environment with the current set of
> NetApp filers.
>=20
> While the root of the problem may be with the tcp-nfs
> implementation on Linux, it is interesting to note
> until a certain load level is generated
> via tcp-nfs accessing a directory on a filer, no
> problems manifest themselves.

to call this an "analysis" is irresponsible.  you ran
some tests, that is all.  true analysis would explain
exactly why this is happening.

> The latest kernel available (2.4.21pre7 + patches via
> Chuck Lever of NetApp) do not appear to fix the
> problem.

i don't know which patches you're referring to.  can
you provide some URLs?  have you reproduced this with
unmodified 2.4.21-pre7 ?  at least one of my patches
removes the "can't get request slot" message, so if
you say you see that message in your kernel log,
"you got some 'splaining to do."

> Until this critical problem is resolved, it is a moot
> point to argue the advantages of tcp-nfs vs. udp-nfs
> regarding network traffic or CPU usage.

this is a little far fetched.  NFS over TCP works
very well in many environments.  NFS over UDP fails
very quickly in many environments.  it is well
known that some experimentation is required to
determine which of TCP or UDP is right to use
in any environment.

now for some detailed criticism:

 +  you don't list your complete set of mount options.

 +  you don't itemize your client hardware (SMP?  NIC
    hardware?  RAM size?  CPU speed?).

 +  you don't provide any network traces or analysis.

 +  you don't provide the output of "nfsstat -c" or
    "netstat -s".

 +  how are your Ethernet switches connected to each
    other?  do you have switch statistics that show
    the switches are behaving?  are the GbE links
    configured for full duplex and full flow control?

 +  when you say "remote directories were unavailable"
    do you mean other processes on the stuck client
    couldn't access files in that directory, or other
    clients that work OK could not access the directories?

 +  can you explain why the problem arises in tests
    A and D, but not in B or C?

let's take this off the list until we have less conjecture
and more facts.

> GORY DETAILS (go get something to drink first):
>=20
> * Tools:
>=20
> traffic generator: iozone (http://www.iozone.org)
> analysis equipment: lump of meat and bone located
> above the shoulders.
>=20
> * Testing Procedure:
>=20
> Three 'control hosts' managed a pool of linux clients
> via iozone to generate traffic to target directories
> stored on the netapp filers below.
>=20
> 1 NetApp Release 6.2.2D21: Fri Feb 28 18:39:39 PST
> 2003 (sphere)
>     exported directory ( /u/admin-test1 quota)
> 1 NetApp Release 6.2.2: Wed Oct 16 01:12:25 PDT 2002
> (vger)
>     exported directory ( /u/admin-test2 qtree)
> 1 NetApp Release 6.2.2: Wed Oct 16 01:12:25 PDT 2002
> (wopr)
>     exported directory ( /u/admin-test3 qtree)
>=20
> Each control host ran a single instance of iozone as
> shown below:
>=20
> ch1: iozone -t 25 -r 64 -s 10000 -+m
> iozone.test1.hosts
> ch2: iozone -t 25 -r 64 -s 10000 -+m
> iozone.test2.hosts
> ch3: iozone -t 25 -r 64 -s 10000 -+m
> iozone.test3.hosts
>=20
> # -t 25 25 concurrent test
> # -r read in 64kb chunks
> # -s size of file in kb
> # -+m extended commands enabled
>=20
> Where the extended command control file contains a
> repetitive series of lines, one per test population
> host.  Each extended command file referenced a
> different nfs-mounted directory from a netapp filer.
>=20
> valk004 /u/admin-test1 /tool/pandora/sbin/iozone
> valk074 /u/admin-test1 /tool/pandora/sbin/iozone
> go064 /u/admin-test1 /tool/pandora/sbin/iozone
> 	.
> 	.
> 	.
>=20
> All filers are connected via fiber gig; all linux
> hosts 100baseTX-FD switched.  Network backbone is
> catalyst 6509 (netapp filers) and catalyst 4000/6506
> (linux clients).
>=20
> * Test Population A:
>=20
> 10 redhat 7.3 running kernel 2.4.18 using tcp-nfs
> 7  redhat 7.3 running kernel 2.4.21pre7 using tcp-nfs
> 6  redhat 7.3 running kernel 2.4.18 using udp-nfs
> 2  redhat 7.1 running kernel 2.4.16 using udp-nfs
>=20
> * Test Results A
>=20
> All clients using tcp-nfs (17/17) fail after a short
> amount of time with the following errors:
>=20
> "nfs server XXX not responding"
> "nfs task XXX can't get a request slot"
>=20
> At which point the remote directories mounted from the
> NetApp filers were unavailable.  An examination of the
> /proc file system shows that the iozone process
> attempting to access the remote file system believes
> it=20
> to be sleeping.
>=20
> Some of the clients using udp-nfs saw the "nfs server
> XXX not responding", but was typically followed with
> "nfs server XXX ok".  At no point did the
> remote directories mounted from the NetApp filers
> become unavailable.
>=20
> Stopping the traffic simulation did not allow the
> clients using tcp-nfs to regain access to the remote
> directories.
>=20
> * Test Population B:
>=20
> 5 redhat 7.3 running kernel 2.4.18 using tcp-nfs
> 7  redhat 7.3 running kernel 2.4.21pre7 using udp-nfs
> 11  redhat 7.3 running kernel 2.4.18 using udp-nfs
> 2  redhat 7.1 running kernel 2.4.16 using udp-nfs
>=20
> * Test Results B:
>=20
> After a test period of 12 hours, no problems were seen
> with access to remote directories for either tcp-nfs
> or udp-nfs clients.
>=20
> * Test Population C:
>=20
> 7  redhat 7.3 running kernel 2.4.21pre7 using udp-nfs
> 16  redhat 7.3 running kernel 2.4.18 using udp-nfs
> 2  redhat 7.1 running kernel 2.4.16 using udp-nfs
>=20
> * Test Results C:
>=20
> After a test period of 3 hours, no problems were seen
> with access to remote directories for udp-nfs clients.
>=20
> * Test Population D:
>=20
> 10 redhat 7.3 running kernel 2.4.18 using tcp-nfs
> 7  redhat 7.3 running kernel 2.4.21pre7 using udp-nfs
> 6  redhat 7.3 running kernel 2.4.18 using udp-nfs
> 2  redhat 7.1 running kernel 2.4.16 using udp-nfs
>=20
> * Test Results D:
>=20
> All clients using tcp-nfs (10/10) fail after
> approximately one hour of time with the following
> errors:
>=20
> "nfs server XXX not responding"
> "nfs task XXX can't get a request slot"
>=20
> At which point the remote directories mounted from the
> NetApp filers were unavailable.  An examination of the
> /proc file system shows that the iozone process
> attempting to access the remote file system believes
> it=20
> to be sleeping.
>=20
> # cat status=20
> Name:   df
> State:  D (disk sleep)
>=20
> Some of the clients using udp-nfs saw the "nfs server
> XXX not responding", but was typically followed with
> "nfs server XXX ok".  At no point did the
> remote directories mounted from the NetApp filers
> become unavailable.
>=20
> Stopping the traffic simulation did not allow the
> clients using tcp-nfs to regain access to the remote
> directories.
>=20
> ANALYSIS / CONCLUSION
>=20
> Linux tcp-nfs is not ready for production in our large
> scale distributed environment with the current set of
> NetApp filers.
>=20
> While the root of the problem may be with the tcp-nfs
> implementation on Linux, it is interesting to note
> until a certain load level is generated
> via tcp-nfs accessing a directory on a filer, no
> problems manifest themselves.
>=20
> The latest kernel available (2.4.21pre7 + patches via
> Chuck Lever of NetApp) does not appear to fix the
> problem.
>=20
> Until this critical problem is resolved, it is a moot
> point to argue the advantages of tcp-nfs vs. udp-nfs
> regarding network traffic or CPU usage.
>=20
>=20
>=20
>=20
> __________________________________________________
> Do you Yahoo!?
> The New Yahoo! Search - Faster. Easier. Bingo
> http://search.yahoo.com
>=20


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
