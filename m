From: "Patrice Seyed" <apseyed@bu.edu>
Subject: nfs performance / Input/output error
Date: Fri, 23 Jul 2004 00:33:36 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <001c01c4706e$38a64230$6401a8c0@psyche1>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <apseyed@bu.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BnrlC-0003RF-Kw
	for nfs@lists.sourceforge.net; Thu, 22 Jul 2004 21:34:18 -0700
Received: from acsn03.bu.edu ([128.197.159.63])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1BnrlC-0006th-4w
	for nfs@lists.sourceforge.net; Thu, 22 Jul 2004 21:34:18 -0700
To: <nfs@lists.sourceforge.net>
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

What I'm addressing is in a cluster environment where when the nfs server is
heavily loaded I see the following in /var/log scrolling:
"can't get a slot request" "not responding, still trying OK"

Also when I am really pounding on the nfs server with hundreds of jobs that
do a 256mb "dd" to an nfs mount, I see this error often "Input/output"
error.

I think I've potentially ruled out driver and settings, also there's no
collisions on server or clients. Any suggestions on further tuning for
performance appreciated. The clients and server are set to 1000/full using
e1000 on the server and tg3 on the clients. I'll indicate the config specs
here:

nfs-utils-1.0.6-21EL
modutils-2.4.26-16
Linux 2.4.21-4.0.1.ELsmp 

auto.home with these options:
rw,hard,intr,rsize=65536,wsize=65536

(I've tried multiples 16k blocks w/o improvement)

/etc/exports:
(rw,no_root_squash)
*not doing async as advised 

/proc/sys/net/core/rmem_default and /proc/sys/net/core/rmem_max set to
262144.

I've increased the number of daemons from 6 to 16 to 32 to 64, no
improvement. Any ideas appreciated.

Regards,
 
Patrice Seyed
Linux System Administrator - SIG
RHCE, SCSA
Boston University School of Medicine




-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
