From: Jeffrey Layton <jtlayton@poochiereds.net>
Subject: Linux' NFS locking b0rken?
Date: Tue, 25 May 2004 08:23:49 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1085487829.6666.32.camel@tesla.mmt.bellhowell.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BSayI-0006cP-5D
	for nfs@lists.sourceforge.net; Tue, 25 May 2004 05:23:54 -0700
Received: from rdu26-93-067.nc.rr.com ([66.26.93.67] helo=salusa.poochiereds.net)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BSayH-0003ZX-Ld
	for nfs@lists.sourceforge.net; Tue, 25 May 2004 05:23:53 -0700
Received: from localhost (localhost [127.0.0.1])
	by salusa.poochiereds.net (Postfix) with ESMTP id BDB0AD997
	for <nfs@lists.sourceforge.net>; Tue, 25 May 2004 08:23:44 -0400 (EDT)
Received: from salusa.poochiereds.net ([127.0.0.1])
	by localhost (salusa [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 06296-10 for <nfs@lists.sourceforge.net>;
	Tue, 25 May 2004 08:23:44 -0400 (EDT)
Received: from localhost (salusa.poochiereds.net [192.168.1.2])
	by salusa.poochiereds.net (Postfix) with ESMTP id B854BCBF2
	for <nfs@lists.sourceforge.net>; Tue, 25 May 2004 08:23:43 -0400 (EDT)
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

I've been doing a little testing of lock handling. My findings seem to
indicate that Linux does not handle NFS locking at all, but I want to
sanity check what I'm doing against the knowledgeable people on this
list.

I wrote a small perl script to do an exclusive lock on a file:

----------------------------------------------
#!/usr/bin/perl
 
use Fcntl qw(:DEFAULT :flock);
 
$file=$ARGV[0];
 
open (FH, "+< $file") or die "Can't open $file: $!\n";
if ( flock(FH, LOCK_EX|LOCK_NB) ) {
    print "Lock acquired! Sleeping for 5 mins...\n";
    sleep 300;
} else {
    print "Unable to acquire lock! Exiting...\n";
    exit 1;
}
 
close FH;
 
exit 0;
-----------------------------------------------

The fileserver is Linux (and I've tried both 2.4 and 2.6 kernels and
seem to get the same result), and for clients, I've tested Solaris 8,
and Linux 2.4 and 2.6. The Linux boxes are Debian machines using 1.0.6
nfs-kernel-server and nfs-common packages.

I then touched a file on the NFS-shared directory and ran this script to
lock it using different clients.

Locking seems to work with 2 Solaris 8 clients. If I run this script
against the same file, then the second one gets the 'Unable to acquire
lock' message.

However, when I try this with 2 Linux clients, or with a Linux and
Solaris client, they both claim to acquire the lock. When I run the test
in 2 terminals on the same Linux client the second one is unable to
acquire the lock, so the problem seems to be in dealing with locks as
registered by the NFS server. 

I've tried several things to work around this problem:

Kernel version does not seem to matter here, at least I see this with
recent versions of both the 2.4 and 2.6 kernel tree, on both clients and
servers.

My mount options for the Linux side are:

nosuid,soft,bg,udp

I've tried other options too, in particular, both NFSv2 and v3, as well
as v3 over TCP. None of that seems to help.

Has anyone successfully been able to get Linux to respect fcntl locking
over NFS? If so, do you have any ideas what I'm doing wrong?

Thanks,
Jeff




-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
