From: Steve Fosdick <lists@pelvoux.nildram.co.uk>
Subject: How to enable debugging on NFS (dprintk)?
Date: Thu, 17 Jul 2003 12:07:25 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030717110725.GA24400@pelvoux.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pelvoux.gotadsl.co.uk ([62.3.242.73])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19d6cE-0006DA-00
	for <nfs@lists.sourceforge.net>; Thu, 17 Jul 2003 04:08:02 -0700
Received: from localhost
	([127.0.0.1] helo=pelvoux ident=fozzy)
	by pelvoux.gotadsl.co.uk with esmtp (Exim 3.36 #1 (Debian))
	id 19d6bd-0006ME-00
	for <nfs@lists.sourceforge.net>; Thu, 17 Jul 2003 12:07:25 +0100
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

There are some calls to dprintk within the NFS kernel code - how to I 
set things up to I can see the messages from these calls please?

Steve.


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
