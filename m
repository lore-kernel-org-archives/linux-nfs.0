From: Robert Sander <ml-linux-nfs@epigenomics.com>
Subject: Re: nfs client's local cache
Date: Mon, 3 Nov 2003 15:46:49 +0000 (UTC)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <news2mail-slrnbqcu39.fis.gurubert-dated-1067850494.pnhelomc@moneta.epigenomics.epi>
References: <482A3FA0050D21419C269D13989C6113127F73@lavender-fe.eng.netapp.com>
Reply-To: Robert Sander <gurubert-dated-1067850494.pnhelomc@epigenomics.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AGgvL-0004xi-00
	for <nfs@lists.sourceforge.net>; Mon, 03 Nov 2003 07:47:23 -0800
Received: from [62.159.77.106] (helo=gk.ka.epigenomics.net ident=qmailr)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.24)
	id 1AGgvB-0006Ow-1p
	for nfs@lists.sourceforge.net; Mon, 03 Nov 2003 07:47:13 -0800
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

On Mon, 3 Nov 2003 15:36:27 +0000 (UTC),
 "Lever, Charles" <Charles.Lever@netapp.com> wrote:
> there are three effects in play here:
> 
> 1.  close-to-open cache coherency
> 2.  weak cache consistency
> 3.  attribute cache timeout
> 
> i suspect you are using NFSv2 on an older 2.4 kernel.  can you provide
> your mount options via "cat /proc/mount" and the output of "uname -a" ?

Hi!

This happened independently on two NFS-Servers with several clients.

1. NFS-Server: 2.4.20 running kernel-nfsd
   Client: 2.4.19-64GB-SMP (SuSE SLES)
           /proc/mounts: rw,v3,rsize=4096,wsize=4096,hard,intr,udp,nolock
   Client: 2.4.20
                         rw,v3,rsize=8192,wsize=8192,hard,intr,udp,nolock

2. NFS-Server: 2.4.20 running userspace-nfsd
   Client: 2.4.19-64GB-SMP (SuSE SLES)
                         ro,v2,rsize=4096,wsize=4096,hard,intr,udp,nolock

The second combination obviously runs NFSv2 but we had that effect with
the first combination and NFSv3, too.

Greetings
-- 
Robert Sander
Manager
Information Systems        www.epigenomics.com        Kastanienallee 24
+493024345330                                              10435 Berlin


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
