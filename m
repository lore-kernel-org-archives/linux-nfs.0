From: Pierre Ossman <drzeus-list@drzeus.cx>
Subject: Move (mv) hangs with NFSv4
Date: Fri, 03 Dec 2004 18:51:22 +0100
Message-ID: <41B0A79A.2010203@drzeus.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CaHaf-0007Hx-0g
	for nfs@lists.sourceforge.net; Fri, 03 Dec 2004 09:51:33 -0800
Received: from a26.t1.student.liu.se
	([130.236.221.26] helo=mail.drzeus.cx ident=daemon)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CaHad-00025F-W1
	for nfs@lists.sourceforge.net; Fri, 03 Dec 2004 09:51:32 -0800
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

I've been trying out NFSv4 instead of NFSv3 on the systems here and have
had mixed success. First of there was an uid/gid mapping bug which was
solved in 2.6.9.

Now I've run into another serious bug; I cannot move files to the NFS
filesystem. It stalls when the file is finished. I've tried with big and
small files (even 0 bytes) and the effect is the same.

I started guessing that it sets some attributes during the final stage
so i tried cp -a, which has the same effect. So this seems to support 
that theory. chmod and chown work fine. I don't know if there is some 
other command I can try that only messes with attributes.

There is no error message on the server. On the client I get "RPC: 
rpciod waiting on sync task!" now and then. Most of the time it doesn't 
say a thing though so I'm not sure it's related.

The server is a FC2 machine running 2.6.9-1.6_FC2 (also tried 2.6.8.1 +
uid/gid patch) and the clients are a FC2 machine with the same kernel
and a FC3 machine with a clean 2.6.9.

Rgds
Pierre


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
