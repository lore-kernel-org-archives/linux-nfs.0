From: Steven Timm <timm@fnal.gov>
Subject: kernel: nfs: task xxxxx can't get a request slot--plus hang
Date: Fri, 24 May 2002 10:05:52 -0500 (CDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.31.0205240952030.16344-100000@boxer.fnal.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <scs-farm@fnal.gov>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from boxer.fnal.gov ([131.225.80.86])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17BGde-0008S8-00
	for <nfs@lists.sourceforge.net>; Fri, 24 May 2002 08:05:54 -0700
To: <nfs@lists.sourceforge.net>
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


I am seeing a large number of error messages in NFS clients

kernel: nfs: task xxxxx can't get a request slot

Once this happens, any attempts to access the nfs volume that the NFS
client was trying to access at the time will hang and add one to the
load.  It is impossible to kill these processes without stopping
and restarting the network. In fact it is impossible to reboot without
stopping the network first.

However, other nfs volumes that are mounted can still be accessed
with no problem.  The volume that hangs is different on different
machines.  It was suggested last week on this list that I should
upgrade the driver for the ethernet card, which I did.  The errors
went away for a week or so and now are back with a vengeance.

These are Linux nfs v3 clients (169 of them), running kernel 2.4.9-31smp
plus Intel's e100 driver version 1.8.38.  No special NFS patches added in.

The server is an SGI Origin 2000 running IRIX 6.5.14.

There is some evidence that the problems are correlated to the
overall network load on the server, but the server is capable of
servicing many more calls than the level it was at (about 3000 calls/sec)
at the time these errors happen.  Also, these errors did not happen
with 2.2.19 kernels and NFS v2.  Furthermore, they happen
in only one of the four hardware types on my cluster--hardware
that is based on SuperMicro 370 DLE boards with Serverworks chipset.


My questions;
1) Is an upgrade to the 2.4.18 kernel likely to help this situation?

2) Are there any special nfs mount options I should be using
in the mount statement on the clients?  (The NFS clients
are reading a lot of small files, not a few big huge files).

3) Is NFS over TCP likely to help this situation at all...if so,
what would be required to make the conversion?  Is it supported
in the stock kernel that comes with RedHAt 7.3?

Steve Timm

------------------------------------------------------------------
Steven C. Timm (630) 840-8525  timm@fnal.gov  http://home.fnal.gov/~timm/
Fermilab Computing Division/Operating Systems Support
Scientific Computing Support Group--Computing Farms Operations


_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
