From: Steve Dickson <SteveD@RedHat.com>
Subject: Re: NFS server export problem
Date: Mon, 20 Oct 2003 18:50:49 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F9466C9.40209@RedHat.com>
References: <sf91d589.045@prv-mail20.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1ABkSt-00042Q-00
	for <nfs@lists.sourceforge.net>; Mon, 20 Oct 2003 17:33:35 -0700
Received: from host-64-179-20-100.man.choiceone.net ([64.179.20.100] helo=Odyssey.Home.4Dicksons.Org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 1ABiuJ-0008MY-7u
	for nfs@lists.sourceforge.net; Mon, 20 Oct 2003 15:53:47 -0700
To: Gobikrishnan Sundharraj <gsundharraj@novell.com>
In-Reply-To: <sf91d589.045@prv-mail20.provo.novell.com>
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



Gobikrishnan Sundharraj wrote:

>Hello,
>
>I installed RedHat 9 on my system and I am trying to setup an NFS
>server. 
>
>On the NFS client, I got the error:
>
>"mount ... failed, reason given by server: permission denied"
>
>and I have traced the problem to the "export" on the server.
>
>On the server, the /proc/fs/nfs/exports does not show what I configured
>to be exported (empty).
>  
>
Look in /var/log/message for any error messages and/or
run the "exportfs -rv" command (as root on the server) to see
if there are any issues...

SteveD.



-------------------------------------------------------
This SF.net email is sponsored by OSDN developer relations
Here's your chance to show off your extensive product knowledge
We want to know what you know. Tell us and you have a chance to win $100
http://www.zoomerang.com/survey.zgi?HRPT1X3RYQNC5V4MLNSV3E54
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
