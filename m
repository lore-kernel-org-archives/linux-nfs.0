From: Wade Hampton <wade.hampton@nsc1.net>
Subject: df hangs on down nfs server mounted with hard,intr, can't kill
Date: Tue, 09 Mar 2004 14:33:01 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <404E1BED.7090608@nsc1.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B0n7V-00042C-KF
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 11:42:29 -0800
Received: from www.nsc1.net ([4.22.175.200] helo=mail.nsc1.net)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1B0myY-00060Y-HW
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 11:33:14 -0800
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

[I posted this to the Fedora list yesterday.]

I have a Fedora server with kernel 2.4.22-1-2163 SMP mounting a
remote solaris server (hence choice of options):

  rsize=32768,ro,hard,intr,tcp,nfsvers=3

When the remote is down or disconnected, a "df" hangs (as expected),
but I can't kill it, even as root or with kill -9.  The docs for mount 
indicate
that the INTR option should allow for killing apps mounted with HARD.
Is this a bug (glibc, 2.4 kernel, NFS, or Fedora's kernel)?

I also coded a test program that calls statvfs(2) and it hangs on
the statvfs(2) call when run against a down NFS server.  It too
can't be interrupted or killed.

My questions are:

1)  Is there a safe and reliable means to check for a down NFS server
    (e.g., is showmount -e <server> safe enough?)

2)  Is the non-interruptable operation (even with INTR option)
    a bug or feature?

3)  Is there a simple kernel call, /proc entry, or similar that can
   be used to reliably check for free/used disk space and for a down
   host, without hanging my application?
  
       A showmount -e followed by a statvfs() might work, but
       there is the possibility of losing the host between the two
       calls, resulting in an application hang.

4)  Is there a perl module to accomplish this?

This would be very useful for network monitoring, e.g., when the
server goes down and stays down for >1 minute, generate an SNMP
trap and write to a log file.  It would be good if you can't put an SNMP
agent on the server, but only on the client.  It is also useful for writing
a highly reliable client application.

As I have no control over the remote system, when it went down,
I had to do a hard reboot of my Linux box to stop the hung apps.  This
is a Windows solution, not a Linux solution....
 
Note, I found this when writing some scripts for MRTG to check
the disk utilization of partitions.  My df's hung so I didn't even get
the proper values for my local partitions.  After a few days, I had
LOTS of hung MRTG apps and had to reboot (this test server is
down for a week or two).

Thanks
-- 
Wade Hampton


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
