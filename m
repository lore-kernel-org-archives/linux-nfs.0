From: "Jarvis Caines" <jcaines@cc.tt>
Subject: slow delivery to MUA over NFS
Date: Thu, 26 Sep 2002 09:07:04 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <43F5978DABDC3544821D6024EDAC82CA01BBB1@posntmail.cc.tt>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [200.12.236.116] (helo=posntmail.cc.tt)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17uYCJ-0002RU-00
	for <nfs@lists.sourceforge.net>; Thu, 26 Sep 2002 05:56:52 -0700
To: <nfs@lists.sourceforge.net>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

I recently set up a remote store for my mail users using NFS.
My mount in fstab looks like this.
192.168.128.4:/home/mailstore   /home nfs  =
nolock,hard,intr,actimeo=3D0,tcp 0 0
I have NFS version 2 and 3 running on Red Hat linux 7.3.Kernel =
2.4.18-10smp.

when i send an email to a mailbox it is delivered instantly to the users =
mail box on the NFS mount.  However, when trying to retrieve the mail =
from a MUA such as Outlook Express or Horde which I have set up for =
Webmail; the MUA is not getting the mail. However, after a long period =
of time, usually an hour or so the mail shows up in my inbox.=20

What could be the problem?=20

Is it a problem with qmail or is it a problem with the NFS share. I have =
read a lot about NFS and confirmed that it is working being mail is =
arriving in the new box within a second.=20

Please send some comments. I am starting to loose my hair.=20

Jarvis Caines

System Admin



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
