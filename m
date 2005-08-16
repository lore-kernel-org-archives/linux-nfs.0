From: Scott Taylor <scottt@methodstudios.com>
Subject: WARNING: rfs3call
Date: Mon, 15 Aug 2005 18:03:53 -0700
Message-ID: <43013B79.2070800@methodstudios.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E4ps6-00052D-QY
	for nfs@lists.sourceforge.net; Mon, 15 Aug 2005 18:04:06 -0700
Received: from mail.methodstudios.com ([205.147.9.194] helo=myo2.methodstudios.com)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1E4ps6-0000ch-IA
	for nfs@lists.sourceforge.net; Mon, 15 Aug 2005 18:04:06 -0700
Received: from [192.168.10.80] (scottPC.methodstudios.com [192.168.10.80])
	by myo2.methodstudios.com (8.12.5/8.12.8) with ESMTP id j7G13udx020858
	for <nfs@lists.sourceforge.net>; Mon, 15 Aug 2005 18:03:56 -0700
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

Hi.

In an environment with a Fedora3 (2.6.11.3 kernel) serving NFS to 
several IRIX (6.5.21) boxen, I occasionally see the following messages 
in the IRIX system's syslogs:

Aug 15 16:03:42 4A:K6 unix: WARNING: rfs3call: file temporarily 
unavailable on the server s2, retrying...
Aug 15 17:44:48 4A:K6 unix: WARNING: rfs3call: file temporarily 
unavailable on the server s2, retrying...
Aug 15 17:46:07 4A:K6 unix: WARNING: rfs3call: file temporarily 
unavailable on the server s2, retrying...


Some of the IRIX boxen weather these messages well, while others (onyx2 
and octane1) will hang for a while.

All of these systems reside on the same gigabit ethernet switch.

The line in the IRIX boxen fstab looks like this :

s2:/array /ocean nfs rw,soft,bg,rsize=32768,wsize=32768,proto=tcp 0 0

Things seemed to be working nicely for a long time, and I cannot 
identify any specific change to the network or machines that may have 
led to these messages.

Many thanks for any thoughts or input - please reply to my email address 
directly as I do not subscribe to the list.

Thanks,

Scott



-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
