From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: RE: Chuck's iostat patch
Date: Tue, 9 Mar 2004 05:58:46 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611302B07BB9@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Olaf Kirch" <okir@suse.de>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B0htq-0006vY-Ox
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 06:08:02 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B0hN7-0000rH-Ru
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 05:34:13 -0800
To: "Jeremy McNicoll" <jeremy@mcnicoll.ca>
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

> I too have done something similar to this for 2.4 and 2.6.  I=20
> believe I=20
> announed it a while ago. You may want to take a look at it here. =20
> http://www.mcnicoll.ca/iostat
>=20
> This is a project for a prof of mine who originally did it=20
> for his PHD,=20
> way back in 2.0.34.   I am just implementing it in 2.4 and=20
> 2.6 for NFS. =20
> The patches are on the website.
>=20
> Where are the patches for Chucks work?

http://plymouth.citi.umich.edu/cel/nfs-client/rhel-3.0/linux-2.4.21-nfs_
metrics.patch

i don't have a 2.6 version nor have i started any modification of
iostat or sar.  i simply wanted to get agreement on APIs and exactly
what metrics we are interested in providing.  as such this is only
a prototype.  there are some ugly things that will change in the
final version (nfs_count_this_op, i believe, is going away).

it creates files under /proc/fs/nfs/stats, one file for each mount
point on the client.  the stat files look something like:

--------  cut here  --------
nfs/stats format version: 1.0
hostname: %s
nfs version: %d

mounted %lu seconds ago
transport idle time: %lu seconds
major timeouts: %lu
transport partial writes: %lu
write_space callbacks: %lu
transport socket type: tcp
connect attempts: %lu
total connect wait time: %Lu usecs
  or
transport socket type: udp

# optype   op count                bytes    retrans     errors
  read:
  write:
  commit:
  getattr:
  lookup:
  readdir:
  symlink:
  readlnk:
  remove:
  other:

ticks/sec: %Lu
# optype      rtt total ticks         sum rtt ** 2  execute total ticks
sum execute ** 2
  read:
  write:
  commit:
  getattr:
  lookup:
  readdir:
  symlink:
  readlnk:
  remove:
  other:

# optype  slot util    backlog  sndq util
  read:
  write:
  commit:
  getattr:
  lookup:
  readdir:
  symlink:
  readlnk:
  remove:
  other:
--------  cut here  --------

the idea being that this file would export raw counts that show
the number of bytes that have been transfered along with errors
and retransmissions, and the RPC latencies and queue utilizations,
with enough data to compute running averages and standard deviation.

the user land tools (iostat and sar, at least) would then be able
to compute and display byte rates, average RPC latencies (per op type),
and so on.  these stats are per-mountpoint and per op type so we
can detect when a server is slow at writes and fast at reads, or
vice versa.

i'd also like to provide cache hit rate statistics, and some info
about RPC scheduling (like how many times, on average, an RPC task
is moved from queue to queue or put to sleep).

there are a few problems with this solution.  one is that zeroing
these counters is not atomic.  another is that umount is racy and
can leave these data structures in a not so friendly state that
could result in an oops.  and i think we all agree that using
seq_file is a much better way to export these metrics to user space.
in the final version we will use sysfs instead of /proc.  it's
not clear how to name the stat files uniquely -- today i'm using
minor numbers, which is a hack.  the export pathname is available only
in the vfsmount structures, so it is entirely unavailable today
for use in the stat files.  in 2.6 we have superblock sharing, and
i'm not sure what exactly that will mean for the "per-mountpoint"
nature of this implementation.

there's a lot of work left to be done.


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
