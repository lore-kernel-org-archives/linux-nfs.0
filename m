From: Steve Fosdick <lists@pelvoux.nildram.co.uk>
Subject: Hang Problem - Linux Server, HP-UX Client
Date: Wed, 16 Jul 2003 13:01:42 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030716120142.GA18956@pelvoux.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pelvoux.gotadsl.co.uk ([62.3.242.73])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ckzF-0002Fz-00
	for <nfs@lists.sourceforge.net>; Wed, 16 Jul 2003 05:02:21 -0700
Received: from localhost
	([127.0.0.1] helo=pelvoux ident=fozzy)
	by pelvoux.gotadsl.co.uk with esmtp (Exim 3.36 #1 (Debian))
	id 19ckyd-0004vq-00
	for <nfs@lists.sourceforge.net>; Wed, 16 Jul 2003 13:01:43 +0100
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

We have a puzzling problem with NFS hanging while using Linux as the 
server and HP-UX as the client.  This happens restoring files from 
backup tape which are being written to the NFS filesystem.  Initially 
files are being written OK but after a while the writing stops and the 
HP-UX client reports "NFS server <hostname> not responding".  At this 
point both client and server continue to work normally in every other 
respect and IP network connectivity between them is still working so 
the problem seems specific to NFS.

Initially it looked like the problem occured after aprox. 4Gb of data 
had been written to the NFS filesystem, but since then it seems to have 
happened after rather less data had been copied.  The problem occurs 
with both the kernel-based NFS server and the user mode NFS server and 
using either NFS V2 or NFS V3 and both before and after the 
installation of the latest NFS patch on the HP-UX client.

The versions I currently have running where we still have the problem 
are Linux 2.4.21 with no additional NFS patches (server) and HP-UX 
10.20 with PHNE_25234 (client).

Does anyone hear have any idea what may be going on here, or useful 
tips as to how I could gather debug information that would help get to 
the bottom of this please?

Steve.


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
