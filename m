From: Pierre Ossman <drzeus-list@drzeus.cx>
Subject: NFSv4 needs restart (permission denied)
Date: Fri, 03 Dec 2004 18:52:00 +0100
Message-ID: <41B0A7C0.1020209@drzeus.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CaHbC-0007Iw-8a
	for nfs@lists.sourceforge.net; Fri, 03 Dec 2004 09:52:06 -0800
Received: from a26.t1.student.liu.se
	([130.236.221.26] helo=mail.drzeus.cx ident=daemon)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CaHb9-00025F-GS
	for nfs@lists.sourceforge.net; Fri, 03 Dec 2004 09:52:05 -0800
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

Whenever I reboot my file server one of my clients has trouble accessing
the exports. I just get permission denied. However, when I restart nfsd
it works fine. The other clients have no problems mounting.

The server is a FC2 machine running 2.6.9-1.6_FC2.
The problem client is a FC3 machine running 2.6.9.
The working clients are both FC2 machines running 2.6.9-1.6_FC2.

Any ideas on what can be wrong or how I can find out what the problem
is? The server does not say anything during these mount requests.

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
