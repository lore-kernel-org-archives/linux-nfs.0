From: Haakon Riiser <haakon.riiser@fys.uio.no>
Subject: lockd: rejected NSM callback from 7f000001:30001
Date: Fri, 1 Sep 2006 15:28:54 +0200
Message-ID: <20060901132854.GA25597@bigboss.venod.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GJ951-0001Ex-RZ
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 06:29:08 -0700
Received: from pat.uio.no ([129.240.10.4])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GJ951-0005TI-6b
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 06:29:08 -0700
Received: from mail-mx3.uio.no ([129.240.10.44])
	by pat.uio.no with esmtp (Exim 4.43) id 1GJ94s-0000W4-KP
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 15:28:58 +0200
Received: from c85-196-100-202.static.sdsl.no ([85.196.100.202]
	helo=bigboss.venod.com)
	by mail-mx3.uio.no with esmtpsa (TLSv1:AES256-SHA:256) (Exim 4.43)
	id 1GJ94p-0006if-42
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 15:28:55 +0200
Received: from hakonrk by bigboss.venod.com with local (Exim 4.62)
	(envelope-from <haakon.riiser@fys.uio.no>) id 1GJ94o-0006iW-Ro
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 15:28:54 +0200
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

A few months ago, I upgraded my file server from FC3 to FC5,
and at the same time, upgraded all of the file server's hardware
except the disks (a single SATA drive that holds the OS plus four
SATA drives in a software RAID5 array).

After this upgrade (at least that's when I think it first started to
happen), I started seeing

  lockd: rejected NSM callback from 7f000001:30001

in dmesg.  It causes no apparent errors, but I'm still wondering
if there's something I should (or can) do about it.  The error
messages seem to pop up at random times -- often at times when the
system is completely idle, but it can be days between each time
they occur.

When the error message is printed, it's always more than one line,
but there's a few seconds (typically 4 or 6) between each message.

Current system info:

kernel-2.6.17-1.2174_FC5
glibc-2.4-8
nfs-utils-1.0.8-3

Regarding the port number above, 30001, I have fixed it to that
value by setting STATD_OUTGOING_PORT=30001 in /etc/sysconfig/nfs.
Could this be causing my problem?  Of course, I shouldn't be asking
this as I could try it out for myself, but it can take days before I
know if it changes anything, so I'll just get some feedback here
before I start experiementing. :)

-- 
 Haakon

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
