From: Simeon Miteff <simeon@up.ac.za>
Subject: Problem starting rpc.svcgssd for NFS4
Date: Mon, 23 Feb 2004 07:59:35 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200402230759.35041.simeon@up.ac.za>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Av9G7-0000R6-Kl
	for nfs@lists.sourceforge.net; Sun, 22 Feb 2004 22:08:03 -0800
Received: from kendy.up.ac.za ([137.215.101.101])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1Av8xX-000723-TY
	for nfs@lists.sourceforge.net; Sun, 22 Feb 2004 21:48:52 -0800
Received: from postino.up.ac.za ([137.215.6.15] helo=mx1.up.ac.za)
	by kendy.up.ac.za with esmtp (Exim 4.24)
	id 1Av98J-00031v-Ao
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 07:59:59 +0200
Received: from b121pc200.up.ac.za ([137.215.121.200] helo=io.ee.up.ac.za)
	by mx1.up.ac.za with esmtp (Exim 4.24)
	id 1Av98I-0006gp-Ue
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 07:59:58 +0200
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

Hi All

I'm using kernel 2.6.3, the patched util-linux and nfs-utils, my kerberos5 
setup is working (tested with openssh), and so far I've done everything as 
described by http://www.citi.umich.edu/projects/nfsv4/linux/, yet I get this 
problem when I try to start rpc.svcgssd:

Feb 20 08:39:11 io gssd[25729]: Using (default) Kerberos realm: "EE.UP.AC.ZA"
Feb 20 08:39:11 io gssd[25729]: Initialized credentials cache
Feb 20 08:39:11 io gssd[25729]: Using credentials cache: 
"FILE:/tmp/krb5cc_machine"
Feb 20 08:39:11 io gssd[25729]: Acquired initial kerberos ticket
Feb 20 08:39:11 io gssd[25729]: failed to 
open /proc/net/rpc/auth.rpcsec.init/channel

Looking in that directory:

simeon@io rpc $ ls -l /proc/net/rpc/
total 0
dr-xr-xr-x    2 root     root            0 Feb 23 07:57 auth.domain
dr-xr-xr-x    2 root     root            0 Feb 20 08:38 auth.unix.ip
-r--r--r--    1 root     root            0 Feb 23 07:57 nfs
-r--r--r--    1 root     root            0 Feb 23 07:57 nfsd
dr-xr-xr-x    2 root     root            0 Feb 20 08:38 nfsd.export
dr-xr-xr-x    2 root     root            0 Feb 20 08:38 nfsd.fh

Any Ideas why /proc/net/rpc/auth.rpcsec.init/channel is missing? I double 
checked the kernel config options...

Regards,
Simeon.
-- 
Mr Simeon Miteff
Department of Electrical, Electronic and Computer Engineering
University of Pretoria
Pretoria
0002
South Africa
Tel: +27 12 420 2434
-----------------------------------------------
This message and attachments are subject to a disclaimer. Please refer
to www.it.up.ac.za/documentation/governance/disclaimer/ for details.


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
