From: gb <bakerg3@yahoo.com>
Subject: (no subject)
Date: Wed, 23 Apr 2003 11:38:59 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030423183859.28233.qmail@web41304.mail.yahoo.com>
Reply-To: greg@bakers.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: charles.lever@netapp.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web41304.mail.yahoo.com ([66.218.93.53])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 198P96-0002Ih-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Apr 2003 11:39:04 -0700
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


...an analysis that I recently undertook is attached
below.  any comments this group would have would be
extremely beneficial.  please include
(XXXbakerg3@yahoo.com.XXX) in the reply in addition to
(XXXnfs@lists.sourceforge.net.XXX)

SUMMARY

During periods of heavy tcp-nfs traffic to a remote
nfs mounted directory on a Network Appliance filer,
linux systems will "freeze" causing processes
accessing that directory to enter an non-interruptible
deadlocked state.  Using udp-nfs mounts these problems
do not manifest themselves.

ANALYSIS and CONCLUSION

Linux tcp-nfs is not ready for production in our large
scale distributed environment with the current set of
NetApp filers.

While the root of the problem may be with the tcp-nfs
implementation on Linux, it is interesting to note
until a certain load level is generated
via tcp-nfs accessing a directory on a filer, no
problems manifest themselves.

The latest kernel available (2.4.21pre7 + patches via
Chuck Lever of NetApp) do not appear to fix the
problem.

Until this critical problem is resolved, it is a moot
point to argue the advantages of tcp-nfs vs. udp-nfs
regarding network traffic or CPU usage.

RECOMMENDATION

Force automount to use udp via the localoptions line
in 
etc/init.d/autofs.

Contact netapp with the deatils of our testing and ask
why a certain load level of tcp-nfs traffic causes
other tcp-nfs clients to go into the weeds.


Any suggestions welcome, please include me (the
poster) in your replies.

Thanks,

--Greg

(Charles, if you've read this far, please contact me
so that I can reference our NetApp case id #).

GORY DETAILS (go get something to drink first):

* Tools:

traffic generator: iozone (http://www.iozone.org)
analysis equipment: lump of meat and bone located
above the shoulders.

* Testing Procedure:

Three 'control hosts' managed a pool of linux clients
via iozone to generate traffic to target directories
stored on the netapp filers below.

1 NetApp Release 6.2.2D21: Fri Feb 28 18:39:39 PST
2003 (sphere)
    exported directory ( /u/admin-test1 quota)
1 NetApp Release 6.2.2: Wed Oct 16 01:12:25 PDT 2002
(vger)
    exported directory ( /u/admin-test2 qtree)
1 NetApp Release 6.2.2: Wed Oct 16 01:12:25 PDT 2002
(wopr)
    exported directory ( /u/admin-test3 qtree)

Each control host ran a single instance of iozone as
shown below:

ch1: iozone -t 25 -r 64 -s 10000 -+m
iozone.test1.hosts
ch2: iozone -t 25 -r 64 -s 10000 -+m
iozone.test2.hosts
ch3: iozone -t 25 -r 64 -s 10000 -+m
iozone.test3.hosts

# -t 25 25 concurrent test
# -r read in 64kb chunks
# -s size of file in kb
# -+m extended commands enabled

Where the extended command control file contains a
repetitive series of lines, one per test population
host.  Each extended command file referenced a
different nfs-mounted directory from a netapp filer.

valk004 /u/admin-test1 /tool/pandora/sbin/iozone
valk074 /u/admin-test1 /tool/pandora/sbin/iozone
go064 /u/admin-test1 /tool/pandora/sbin/iozone
	.
	.
	.

All filers are connected via fiber gig; all linux
hosts 100baseTX-FD switched.  Network backbone is
catalyst 6509 (netapp filers) and catalyst 4000/6506
(linux clients).

* Test Population A:

10 redhat 7.3 running kernel 2.4.18 using tcp-nfs
7  redhat 7.3 running kernel 2.4.21pre7 using tcp-nfs
6  redhat 7.3 running kernel 2.4.18 using udp-nfs
2  redhat 7.1 running kernel 2.4.16 using udp-nfs

* Test Results A

All clients using tcp-nfs (17/17) fail after a short
amount of time with the following errors:

"nfs server XXX not responding"
"nfs task XXX can't get a request slot"

At which point the remote directories mounted from the
NetApp filers were unavailable.  An examination of the
/proc file system shows that the iozone process
attempting to access the remote file system believes
it 
to be sleeping.

Some of the clients using udp-nfs saw the "nfs server
XXX not responding", but was typically followed with
"nfs server XXX ok".  At no point did the
remote directories mounted from the NetApp filers
become unavailable.

Stopping the traffic simulation did not allow the
clients using tcp-nfs to regain access to the remote
directories.

* Test Population B:

5 redhat 7.3 running kernel 2.4.18 using tcp-nfs
7  redhat 7.3 running kernel 2.4.21pre7 using udp-nfs
11  redhat 7.3 running kernel 2.4.18 using udp-nfs
2  redhat 7.1 running kernel 2.4.16 using udp-nfs

* Test Results B:

After a test period of 12 hours, no problems were seen
with access to remote directories for either tcp-nfs
or udp-nfs clients.

* Test Population C:

7  redhat 7.3 running kernel 2.4.21pre7 using udp-nfs
16  redhat 7.3 running kernel 2.4.18 using udp-nfs
2  redhat 7.1 running kernel 2.4.16 using udp-nfs

* Test Results C:

After a test period of 3 hours, no problems were seen
with access to remote directories for udp-nfs clients.

* Test Population D:

10 redhat 7.3 running kernel 2.4.18 using tcp-nfs
7  redhat 7.3 running kernel 2.4.21pre7 using udp-nfs
6  redhat 7.3 running kernel 2.4.18 using udp-nfs
2  redhat 7.1 running kernel 2.4.16 using udp-nfs

* Test Results D:

All clients using tcp-nfs (10/10) fail after
approximately one hour of time with the following
errors:

"nfs server XXX not responding"
"nfs task XXX can't get a request slot"

At which point the remote directories mounted from the
NetApp filers were unavailable.  An examination of the
/proc file system shows that the iozone process
attempting to access the remote file system believes
it 
to be sleeping.

# cat status 
Name:   df
State:  D (disk sleep)

Some of the clients using udp-nfs saw the "nfs server
XXX not responding", but was typically followed with
"nfs server XXX ok".  At no point did the
remote directories mounted from the NetApp filers
become unavailable.

Stopping the traffic simulation did not allow the
clients using tcp-nfs to regain access to the remote
directories.

ANALYSIS / CONCLUSION

Linux tcp-nfs is not ready for production in our large
scale distributed environment with the current set of
NetApp filers.

While the root of the problem may be with the tcp-nfs
implementation on Linux, it is interesting to note
until a certain load level is generated
via tcp-nfs accessing a directory on a filer, no
problems manifest themselves.

The latest kernel available (2.4.21pre7 + patches via
Chuck Lever of NetApp) does not appear to fix the
problem.

Until this critical problem is resolved, it is a moot
point to argue the advantages of tcp-nfs vs. udp-nfs
regarding network traffic or CPU usage.




__________________________________________________
Do you Yahoo!?
The New Yahoo! Search - Faster. Easier. Bingo
http://search.yahoo.com


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
