From: Jake Gold <jake@staunch.org>
Subject: Linux NFS and NetApp Performance?
Date: Mon, 19 May 2003 14:56:43 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030519145643.29368baf.jake@staunch.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail01.dtiserv2.com ([216.101.214.6])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Hscj-00005f-00
	for <nfs@lists.sourceforge.net>; Mon, 19 May 2003 14:56:49 -0700
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

I know this might be more of a NetApp question, but here's hoping some people on this list might have some ideas ;-)

I have two web serving platforms I'm working with.

Setup #1:
A cluster of machines mounting a (12 disk RAID5) disk over fiber channel.
Using GFS on top of that to handle the sharing issues (locking, etc).


Setup #2:
A cluster of machines mounting an NFS (v3) volume from a NetApp FAS940 filer over gigabit copper, with three trunked gigabit connections from the NetApp.
Using a DS14 disk shelf with one parity disk, and one hot spare.


Fairly standard stuff...The idea is to present the same exact data across all of the web servers, so they can be load balanced.

The major difference between these two platforms is the way they end up with a web-data volume to serve from, other things like web server and kernel versions
are similar or the same.

But..here's my problem..performance from #2 has been pretty miserable..
systat -u 1 on the filer reports ~55Mbyte/s to the network interface and about the same for reads from the disk (the difference is due to caching, I assume).

I'm getting significantly greater performance out of #1, somewhere in excess of ~125Mbyte/s in reads.

I'm not necessarily expecting to get the same performance from #2, with the overhead of NFS and the higher level on which
it operates (NFS/application vs raw disk access like GFS). Somewhere in the same neighborhood would suffice :)

The bottleneck for #2 definitely seems to be the disks, they reach 100% utilization (according to sysstat and statit on the filer).

When I created the RAID group on the filer I did it all at once as a 13 disk group (14th disk is hot spare). All disks are at roughly
the same utilization percentage according to statit. So, while it could be a problem with the RAID setup, I think I followed the NetApp instructions
pretty carefully.

My guess is that NFS is causing disk access to be inefficient in some way, perhaps lowering overall performance?
I'm working on separating my large files from my smaller files on different disk shelves so I can benefit from aggressive read aheads for my larger files. The problem is, I didn't have this problem at all with setup #1.

I guess my real question: is anyone else using a 900 series filer for web serving over NFS?
If so, what kind of numbers are you seeing?

I'll happily reply with any information that would be helpful.

Thanks in advance,
Jake


-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
