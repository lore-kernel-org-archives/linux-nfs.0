From: "Rousak, Boris" <Boris.Rousak@actewagl.com.au>
Subject: unstable nfs client???
Date: Wed, 18 Jun 2003 09:33:34 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <69A0D39D490CD41198DC00D0B73C369E03A9A826@mail2.actew.oz.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [202.14.248.111] (helo=gateway02.actewagl.com.au)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19SPz7-0005b0-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Jun 2003 16:35:29 -0700
To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
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


Good morning all,
I am currently having some problems with nfs client on redhat, so if this is
an incorrect list to post to I do apologise and would someone point me to
the correct one please. Problem is as follows:
I am running redhat 7.3 kernel 2.4.18-3 with nfs-utils-0.3.3-5 . I am using
the nfs client to mount around 10 shares from various tru64 v5.1 machines.
When I allow 1 or 2 users to access these shares from the Linux server
things work fine, however when 10 to 20 users try to access these shares 
* users have to wait for a long time to be able to see anything in them, 
* often shares crash eventually users get the unable rich server message
* I am unable to unmount the shares (actually the only way for me to do it
becomes to restart the mountd daemon, then unmount them, then remount
everything)
Has anyone got any suggestions on what I am doing wrong? Or is this some
well know bug that I am unable to find through google? If there are nay
other details that you wish to know, please email me.
Thanks,
Regards,
Boris

++++++++++++++++++++++++
Boris Rousak
Unix systems, BSD
ActewAGL
Ph: 6270 7468
Fax: 6270 7464
++++++++++++++++++++++++


************************************************************************
*PLEASE NOTE*  This email and any attachments may
be confidential. If received in error, please delete all 
copies and advise the sender. The reproduction or 
dissemination of this email or its attachments is 
prohibited without the consent of the sender.

WARNING RE VIRUSES:  Our computer systems sweep
outgoing email to guard against viruses, but no warranty 
is given that this email or its attachments are virus free. 
Before opening or using attachments, please check for 
viruses.  Our liability is limited to the re-supply of any 
affected attachments.

Any views expressed in this message are those of the 
individual sender, except where the sender expressly,
and with authority, states them to be the views of the 
organisation.
************************************************************************


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
