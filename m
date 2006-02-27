From: Simon Gao <gao@schrodinger.com>
Subject: Compare binary or data files in different nfs share
Date: Mon, 27 Feb 2006 11:22:28 -0800
Message-ID: <44035174.2060500@schrodinger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FDnx0-0004Vy-00
	for nfs@lists.sourceforge.net; Mon, 27 Feb 2006 11:22:30 -0800
Received: from thermidore.schrodinger.com ([192.156.98.99] helo=schrodinger.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FDnwy-0003Ow-PF
	for nfs@lists.sourceforge.net; Mon, 27 Feb 2006 11:22:30 -0800
Received: from [192.156.98.12] (ithi.schrodinger.com [192.156.98.12])
	by schrodinger.com (8.13.4/8.12.8) with ESMTP id k1RJMGGs007398
	for <nfs@lists.sourceforge.net>; Mon, 27 Feb 2006 11:22:17 -0800 (PST)
	(envelope-from gao@schrodinger.com)
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

Hi,

Not sure if anyone has seen this kind of problem. I have two NFS shares,
one provided by EMC box, one by Gentoo Linux machine (kernel 2.6.15). 
The source directory is on the EMC machine, destination on the Linux
machine. The client machine runs CentOS 4.2 (kernel 2.6.9-22.0.2.ELsmp).


When untar large tarball of many binary and data files (range from 50 MB
to 700 MB) from source to destination, the uncompressed binary files are
different from the ones in source directory if using diff to compare.
What are the possible reasons to cause the difference?

The local filesystem on the Linux nfs server is reiserfs. Exports file
is set to use "sync,wdelay". Client side uses autofs with  
"rw,nosuid,hard,intr,nfsvers=3,udp".

Simon Gao


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
