From: Ralph Churchill <mrchucho@yahoo.com>
Subject: clients too fast?
Date: Mon, 20 Oct 2003 13:45:13 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20031020204513.60004.qmail@web11407.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1ABgyG-0004eH-00
	for <nfs@lists.sourceforge.net>; Mon, 20 Oct 2003 13:49:44 -0700
Received: from web11407.mail.yahoo.com ([216.136.131.237])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1ABgwu-0004E8-Kj
	for nfs@lists.sourceforge.net; Mon, 20 Oct 2003 13:48:20 -0700
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

Is there a minimum amount of time that a file must
"exist" on a server to be visible to all clients? In
other words, if one client creates a file, but then
very quickly deletes it, is it possible that the file
would never be seen by other clients?

If so, is there a rememdy to this "problem" short of
putting some sort of delay in the client's
write/delete sequence? 

Thanks.

RMC

__________________________________
Do you Yahoo!?
The New Yahoo! Shopping - with improved product search
http://shopping.yahoo.com


-------------------------------------------------------
This SF.net email is sponsored by OSDN developer relations
Here's your chance to show off your extensive product knowledge
We want to know what you know. Tell us and you have a chance to win $100
http://www.zoomerang.com/survey.zgi?HRPT1X3RYQNC5V4MLNSV3E54
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
