From: Jordi Prats <jprats@cesca.es>
Subject: about /proc/net/rpc/nfsd
Date: Mon, 22 Oct 2007 23:36:56 +0200
Message-ID: <471D17F8.5060709@cesca.es>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ik4qo-0007ks-QD
	for nfs@lists.sourceforge.net; Mon, 22 Oct 2007 14:30:18 -0700
Received: from carlit.cesca.es ([84.88.0.2])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1Ik4qt-0005Af-OO
	for nfs@lists.sourceforge.net; Mon, 22 Oct 2007 14:30:24 -0700
Received: from carlit.cesca.es (localhost [127.0.0.1])
	by carlit.cesca.es (Postfix) with ESMTP id 9C806331CF9
	for <nfs@lists.sourceforge.net>; Mon, 22 Oct 2007 23:29:51 +0200 (CEST)
Received: from [213.97.212.36] (36.Red-213-97-212.staticIP.rima-tde.net
	[213.97.212.36])
	by carlit.cesca.es (Postfix) with ESMTP id A7F63331CF6
	for <nfs@lists.sourceforge.net>; Mon, 22 Oct 2007 23:29:50 +0200 (CEST)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi all,
I've been researching the meaning of the contents of the 
/proc/net/rpc/nfsd file using the 2.6.23 kernel sources.

$ cat /proc/net/rpc/nfsd
rc 0 959398 336415498
fh 0 0 0 0 0
io 743250564 1224442800
th 16 9193 1322.293 121.816 246.724 134.568 138.140 84.223 32.349 37.372 
7.716 28.454
ra 32 2044764 555 263 206 115 119 82 89 98 64 50896
net 337376442 0 337375903 1956
rpc 337333487 12 12 0 0
proc2 18 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
proc3 22 41 322956721 70371 521208 10500197 134 2096930 779219 48538 
4760 1 0 40535 4351 11538 0 0 19386 57668 47 0 222804
proc4 2 0 0

This is what I've learned:

* rc (reply cache): <hits> <misses> <nocache> (according a thread on 
this list from Chuck Leaver and Thomas Talpey with me)
- hits: client it's retransmiting (a bad thing! o hits is good)
- misses: a operation that requires caching
- nocache: a operation that no requires caching

* fh (filehandle): <stale> <total-lookups> <anonlookups> 
<dir-not-in-cache> <nodir-not-in-cache>
- stale: *supose* to be file handle errors (like when you resize the 
underlying filesystem)
- total-lookups, anonlookups, dir-not-in-cache, nodir-not-in-cache: do 
not appear (and I always seen it as zeros). So I supose they are unused.

* io (input/output): <bytes-read> <bytes-written>
- bytes-read: bytes read directly from disk
- bytes-written: bytes written to disk

* th (threads): <threads> <fullcnt> <10%-20%> <20%-30%> ... <90%-100%> 
<100%>
  - threads: number of nfsd threads
  - fullcnt: number of times that the last 10% of threads  (so all 
threads) are busy.
  - 10%-20%, 20%-30% ... 90%-100%: 10 numbers representing 10-20%, 
20-30% to 100%. Counts the number of times a given interval are busy. 
For example you have 10 threats and you get this:
12 11 10 9 8 7 6 5 4 3

12 times the thread 1 was busy, 11 times the thread 2 was busy, 10 time 
the thread 3 was busy, and so on...

* ra (read-ahead): <cache-size> <10%> <20%> ... <100%> <not-found>
- cache-size: always the double of number threads
- 10%, 20% ... 100%: how deep it found what was looking for. I *suppose* 
this means how far the cached block is from the original block that was 
first requested.
- not-found: not found in the read-ahead cache

* net: <netcnt> <netudpcnt> <nettcpcnt> <nettcpconn>
- netcnt: counts every read
- netudpcnt: counts every UDP packet it receives
- nettcpcnt: counts every time it receives data from a TCP connection
- nettcpconn: count every TCP connection it receives

* rpc: <rpccnt> <rpcbadfmt+rpcbadauth+rpcbadclnt> <rpcbadfmt> 
<rpcbadauth> <rpcbadclnt>
- rpccnt: counts all rpc operations
- rpcbadfmt: counts if while processing a RPC it encounters the 
following errors: err_bad_dir, err_bad_rpc, err_bad_prog, err_bad_vers, 
err_bad_proc, err_bad
- rpcbadauth: bad authentication. It does not count if you try to mount 
from a machine that it's not in your exports file
- rpcbadclnt: unused

I've had no time to investigate about proc<N>. I *supose* that N is the 
protocol version (2 for NFS2, 3 for NFS3 and 4 for NFSv4) So they are 
stats about operations from a given protocol. I'll research this in short.


Sorry for this so long mail... That's all what I've got reading the 
source files. There's anything incorrect? There's some "educated guests" 
  So, could anyone please confirm or refute them?

If you what me to do something with this I'd be glad of it!

regards,
Jordi




-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
