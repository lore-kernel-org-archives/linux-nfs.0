From: Andrew Ryan <andrewr@nam-shub.com>
Subject: NFSv3/TCP client hangs under load (2.4.17+NFS_ALL)
Date: Fri, 12 Apr 2002 19:22:23 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <0204122022230I.01167@stinkpad060501>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from laswell.sfo.collab.net ([64.125.134.138])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16wELb-0002PD-00
	for <nfs@lists.sourceforge.net>; Fri, 12 Apr 2002 20:37:07 -0700
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

I am getting NFS client hangs under load with v3/TCP that I can almost 
reliably reproduce.

The setup:
Run a couple of processes that hit the NFS client hard. In my case, 4 
simultaneous bonnie++ runs, and a simple perl script that exercises file 
locking on NFS. It's not clear I need that many bonnie++'s, but that's what I 
was using. Running the file locking script seems essential to triggering the 
bug, but I can't be totally sure. It takes me anywhere from 15 minutes to 2 
hours of running this workload to trigger a hang.

The client host is running 2.4.17+NFS_ALL, smp ; otherwise more or less a 
stock RH7.2 system. The mount uses the following options:
v3,tcp,intr,hard,rsize=32768,wsize=32768
The server is a Netapp, fwiw.

The symptom:
The NFS mount on the client completely hangs, as do any processes that are 
using it. Other mount points on the same server can be accessed from the 
client -- in fact the same mount point on the server can be mounted and 
accessed fine, in a different place on the client while the hang is going on. 
The following error appears in the kernel at the beginning of the hang:
Apr 12 19:57:07 testhost kernel: nfs_statfs: statfs error = 512
After that nothing, until the mount comes back.

Fixing the problem:
The only way to get out of this situation is to kill the 'offending' process. 
In my case, either the perl script or the bonnie++'s. Then after sending kill 
signals to each process, a minute so or later, the mount will come back. 
Otherwise I have waited >20 minutes and the mount has still been hung.

While the system is hung, turning on /proc/sys/sunrpc/rpc_debug reveals the 
following to the kernel log. It looks like something is waking up every 5 
seconds and trying to process the same request, and failing, and going into 
some sort of infinite loop.

I'm wondering if anyone can help me debug this problem. At the very least I 
intend to try UDP to see if that avoids this problem. But my tests have shown 
that TCP is somewhat faster, so I'd like to use that if possible, although 
stability is more important right now.

Output to kernel log with rpc_debug on while mount is hung:
Apr 12 19:59:47 testhost kernel: RPC:      tcp_data_ready...
Apr 12 19:59:47 testhost kernel: RPC:     xprt queue f779c000
Apr 12 19:59:47 testhost kernel: RPC:      tcp_data_ready client f779c000
Apr 12 19:59:47 testhost kernel: RPC:      state 1 conn 1 dead 0 zapped 0
Apr 12 19:59:47 testhost kernel: rpciod_tcp_dispatcher: Queue Running
Apr 12 19:59:47 testhost kernel: rpciod_tcp_dispatcher: Processing f779c000
Apr 12 19:59:47 testhost kernel: RPC:      tcp_input_record
Apr 12 19:59:52 testhost kernel: RPC:      tcp_data_ready...
Apr 12 19:59:52 testhost kernel: RPC:     xprt queue f779c000
Apr 12 19:59:52 testhost kernel: RPC:      tcp_data_ready client f779c000
Apr 12 19:59:52 testhost kernel: RPC:      state 1 conn 1 dead 0 zapped 0
Apr 12 19:59:52 testhost kernel: rpciod_tcp_dispatcher: Queue Running
Apr 12 19:59:52 testhost kernel: rpciod_tcp_dispatcher: Processing f779c000
Apr 12 19:59:52 testhost kernel: RPC:      tcp_input_record
Apr 12 19:59:57 testhost kernel: RPC:      tcp_data_ready...
Apr 12 19:59:57 testhost kernel: RPC:     xprt queue f779c000
Apr 12 19:59:57 testhost kernel: RPC:      tcp_data_ready client f779c000
Apr 12 19:59:57 testhost kernel: RPC:      state 1 conn 1 dead 0 zapped 0
Apr 12 19:59:57 testhost kernel: rpciod_tcp_dispatcher: Queue Running
Apr 12 19:59:57 testhost kernel: rpciod_tcp_dispatcher: Processing f779c000
Apr 12 19:59:57 testhost kernel: RPC:      tcp_input_record
Apr 12 20:00:02 testhost kernel: RPC:      tcp_data_ready...
Apr 12 20:00:02 testhost kernel: RPC:     xprt queue f779c000
Apr 12 20:00:02 testhost kernel: RPC:      tcp_data_ready client f779c000
Apr 12 20:00:02 testhost kernel: rpciod_tcp_dispatcher: Queue Running
Apr 12 20:00:02 testhost kernel: rpciod_tcp_dispatcher: Processing f779c000
Apr 12 20:00:02 testhost kernel: RPC:      tcp_input_record
Apr 12 20:00:02 testhost kernel: RPC:      state 1 conn 1 dead 0 zapped 0
Apr 12 20:00:07 testhost kernel: RPC:      tcp_data_ready...
Apr 12 20:00:07 testhost kernel: RPC:     xprt queue f779c000
Apr 12 20:00:07 testhost kernel: RPC:      tcp_data_ready client f779c000
Apr 12 20:00:07 testhost kernel: rpciod_tcp_dispatcher: Queue Running
Apr 12 20:00:07 testhost kernel: rpciod_tcp_dispatcher: Processing f779c000
Apr 12 20:00:07 testhost kernel: RPC:      tcp_input_record
Apr 12 20:00:07 testhost kernel: RPC:      state 1 conn 1 dead 0 zapped 0


Perl script used to exercise file locking:
#!/usr/bin/perl
 
use strict;
use Fcntl qw(:DEFAULT :flock);;
 
my $dir=$ARGV[0] || "/shared/data/test";
 
my $filename = "$dir/$$.test";
 
while (1 == 1) {
    open(FILE, ">$filename") or die "Can't open file: $!\n";
    flock FILE, LOCK_EX or die "Can't lock file: $!\n";
    print FILE "Hello world\n";
    close FILE;
    lstat FILE;
    unlink($filename);
}


Any ideas much appreciated.


thanks,
andrew

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
