From: Chris Osicki <osk@admin.swisscom-mobile.ch>
Subject: Q: NFS server cluster
Date: Fri, 31 Mar 2006 16:02:17 +0200
Message-ID: <20060331160217.1734f710@mwdsp001.swissptt.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FPKA9-0002iw-Jo
	for nfs@lists.sourceforge.net; Fri, 31 Mar 2006 05:59:41 -0800
Received: from outmail3.swisscom.com ([138.190.3.30] helo=mrz.swissptt.ch)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1FPKA8-00027W-8i
	for nfs@lists.sourceforge.net; Fri, 31 Mar 2006 05:59:41 -0800
Received: from mwdsp001.swissptt.ch (mwdsp001.swissptt.ch [10.221.40.203])
	by mrz.swissptt.ch with ESMTP id k2VDxPSs007815
	(using TLSv1/SSLv3 with cipher EDH-RSA-DES-CBC3-SHA (168 bits) verified NO)
	for <nfs@lists.sourceforge.net>; Fri, 31 Mar 2006 15:59:30 +0200 (MEST)
Received: from mwdsp001.swissptt.ch (localhost [127.0.0.1])
	by mwdsp001.swissptt.ch (8.13.4/8.13.4) with ESMTP id k2VE2HsL031992
	for <nfs@lists.sourceforge.net>; Fri, 31 Mar 2006 16:02:21 +0200
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

Hi

I've setup a two nodes Linux Cluster (Service Guard) as a NFS server.
They share storage which comes from two Clariions and do host based 
mirroring (RAID1) using the standard Linux RAID driver: md.
So, when activating I assemble the array with mdadm --assemble,
then I activate LVM by running vgchange -ay then I mount the
LVOLs and export them. Everything's fine.
My testclient mounts the exported filesystem and then runs a program 
which opens a file on the NFS-mounted filesystem and writes every
second few words into it.

Now if I initiate a fail-over (on the currently active node: unexport,
umount, vgchange -an, mdadm --stop and activate second node as
describe above) I get two kind of behaviour on the client:

1. Client doesn't notice the fail-over and I see it really happily 
   writing to the file (I checked on the server)

2. Client hangs for about nine minutes (during this time I get a "NFS
   server mstlnfsv1 not responding still trying" when trying to read
   this file and then the client recovers.

Few minutes later (sorry for being not precise, I've just started my
experimenting) the clients reports:

NFS getattr failed for server mstlnfsv1: error 7 (RPC: Authentication error)
NFS write failed for server mstlnfsv1: error 7 (RPC: Authentication error)
Error writing to /mnt/osk/testfile: Permission denied
NFS commit failed for server mstlnfsv1: error 7 (RPC: Authentication error)
NFS commit failed for server mstlnfsv1: error 7 (RPC: Authentication error)
NFS commit failed for server mstlnfsv1: error 7 (RPC: Authentication error)
NFS commit failed for server mstlnfsv1: error 7 (RPC: Authentication error)
NFS commit failed for server mstlnfsv1: error 7 (RPC: Authentication error)
NFS commit failed for server mstlnfsv1: error 7 (RPC: Authentication error)
NFS commit failed for server mstlnfsv1: error 7 (RPC: Authentication error)

Now I cannot access this file:

ls -l /mnt/osk/testfile
NFS getattr failed for server mstlnfsv1: error 7 (RPC: Authentication error)
ls: /mnt/osk/testfile: Permission denied


The testclient is a Sparc/Solaris10 machine.

Is there anything I can do to eliminate this behaviour?
If I understand correctly the problem is on the server side for the
client nothing changes, the same IP-address to talk to, the same
filesystem/filehandle. Or am I missing something.

I would be very thankfull for any help.

Regards,
Chris


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
