From: Juri Haberland <list-linux.nfs@spoiled.org>
Subject: Re: Mailbox corruption on The NFS server
Date: Tue, 2 Dec 2003 18:51:17 +0000 (UTC)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <news2mail-bqimv5$onp$1@cartman.spoiled.org>
References: <Pine.LNX.4.44.0312011235290.23297-100000@kenzo.iwr.uni-heidelberg.de> <Pine.GSO.4.44.0312021646390.9111-100000@bhairav.ee.iitb.ac.in>
Reply-To: Juri Haberland <juri@koschikode.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ARFby-0000WU-FH
	for nfs@lists.sourceforge.net; Tue, 02 Dec 2003 10:51:02 -0800
Received: from cartman.spoiled.org ([80.190.101.194] helo=a.mx.spoiled.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1ARFbx-0006rw-PM
	for nfs@lists.sourceforge.net; Tue, 02 Dec 2003 10:51:01 -0800
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

Shivaji Navale <shivaji@ee.iitb.ac.in> wrote:
> Hi,

Hi,

please don't start a new topic/thread by just replying to another mail.
Thanks.

> We have this peculiar problem for the Mailboxes of users
> /var/spool/mail/username.
> The mailboxes get corrupted asto the first 20-26 lines of mailbox get
> DELETED.
> 
> We are using 2.4.20-18.8.um.1 kernel on the (LVS Director) which exports
> the mail partition to 30 NFS/NIS clients.

It's considered a bad idea to put mailboxes on a NFS share as there
might be locking issues if two applications simultanously acces the same
mailbox. Either use the maildir format or don't export your mailboxes
via NFS.

Regards,
Juri

-- 
Juri Haberland  <juri@koschikode.com> 



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
