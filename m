From: Oren Held <oren@held.org.il>
Subject: try tcp first; then udp
Date: Sat, 01 Nov 2003 17:34:49 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1067700887.5055.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AFxmE-0004hv-00
	for <nfs@lists.sourceforge.net>; Sat, 01 Nov 2003 07:34:58 -0800
Received: from 82-166-124-163.barak.net.il ([82.166.124.163] helo=fourbox.held.org.il)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AFxmD-0008Tq-L7
	for nfs@lists.sourceforge.net; Sat, 01 Nov 2003 07:34:57 -0800
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

Hi,

I wonder if there's a way to mount an nfs share without specifying tcp
or udp mount. I think that this is how Solaris behaves: it tries first
tcp, if it's not good, then it tries udp.

I've been looking for such a mount option and found none; I think it can
be really useful when one has hetrogenous nfs servers (some use tcp,
some use udp) - in the case I just want it to work and don't care which
protocol it'll use.

Is there a way to do it with the current kernel/mount versions?

10x

 - Oren



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
