From: "Charles Duffy" <ccd@mailcall.com.au>
Subject: Data coherency trouble with multiple clients, on 2.6.14-rc5
Date: Wed, 26 Oct 2005 16:01:26 +1000
Message-ID: <ef97ar3j.yzmpka2thm8d@a1g2zg0c>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EUeSI-0002oT-H9
	for nfs@lists.sourceforge.net; Tue, 25 Oct 2005 23:08:10 -0700
Received: from mailadsl.gw.pacific.net.au ([202.7.91.241] helo=newadsl.mailcall.com.au)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EUeSF-0004R5-PY
	for nfs@lists.sourceforge.net; Tue, 25 Oct 2005 23:08:10 -0700
Received: from localhost (newadsl.mailcall.com.au [127.0.0.1])
	by newadsl.mailcall.com.au (Postfix) with ESMTP id 6A2C329797
	for <nfs@lists.sourceforge.net>; Wed, 26 Oct 2005 16:07:55 +1000 (EST)
Received: from newadsl.mailcall.com.au ([127.0.0.1])
 by localhost (newadsl.mailcall.com.au [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 07954-01 for <nfs@lists.sourceforge.net>;
 Wed, 26 Oct 2005 16:07:54 +1000 (EST)
Received: from adm3.mailcall.com.au (adm3.mailcall.com.au [172.17.0.110])
	by newadsl.mailcall.com.au (Postfix) with ESMTP id 3DDDF2976E
	for <nfs@lists.sourceforge.net>; Wed, 26 Oct 2005 16:07:54 +1000 (EST)
Received: from [127.0.0.1] (cabbage.mailcall.com.au [172.17.16.3])
	by adm3.mailcall.com.au (Postfix) with ESMTP id 3A0D141CA07
	for <nfs@lists.sourceforge.net>; Wed, 26 Oct 2005 16:07:54 +1000 (EST)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

Hi all,

I'm hoping someone can shed some light on this problem I'm having.

I have 2 NFS client machines (CentOS 4, kernel 2.6.14-rc5+latest 'NFS_ALL'=
 patch, nfsutils 1.0.6) who each mount the same export from an NFS server (=
WBEL3, kernel 2.4.21-20, nfsutils 1.0.6).

These client machines are supposed to run an in-house database application=
 - multiple processes on different clients often have the same datafile op=
en simultaneously (via NFS).

Previously, we had these client machines running 2.2.21 kernels. The old (=
pre-CTO) behaviour would see writes from any of the clients becoming immed=
iately 'visible' in any of the others. This is no longer the case, even wi=
th 'nocto' specified as a mount option.

Currently, if a process on client1 has the file open while it is written t=
o by another process (on client2), the changes made to the file are never r=
eflected in the data available to the process on client1 unless:

a) client1's NFS filesystem is unmounted and re-mounted
b) The file is 'touched' on the server or on client2 after both processes h=
ave closed the file
c) The process on client1 writes to the file (note 'touching' the file on c=
lient1 has no effect, either while or after the process has the file open)=
.

It doesn't matter if both processes subsequently close the file and exit, t=
hen re-open the file from scratch - the discrepancy remains until either (=
a), (b) or (c) occurs. Client1 and client2 are identical systems, and the p=
roblem works both ways. In the event of (c), the previous write becomes vi=
sible to client1, but the write by client1 is not visible to client2.

'stat' run on the datafile from either client always gives the same output=
.

I've also tried adding O_SYNC to the flags in the call to 'open()' in the a=
pplication itself. Makes no difference.=C2=A0 fsync()ing after every write=
 similarly makes no difference to the problem.

This problem appears similar to that which the linux-2.6.14-01-fix_attrcac=
he patch was posted in response to, but it can't be reproduced with the pr=
ocedure outlined in that post.

The client mount options are: noac,nocto,sync,hard,intr,rw,nfsvers=3D3
The server exports flags are: (rw,no_root_squash,sync,no_wdelay,insecure)

Various combinations of the above mount options make no difference.
I've also tried with a 2.6.14-rc5 server, and the problem persists.

Thanks,



---
Charles Duffy
Systems Administrator
Mail Call Couriers





-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
