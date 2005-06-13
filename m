From: Oded Maimon <oded.maimon@gmail.com>
Subject: NFS High Availability Cluster
Date: Mon, 13 Jun 2005 11:55:44 +0200
Message-ID: <42AD5820.4060109@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DhkjQ-0003yQ-Bk
	for nfs@lists.sourceforge.net; Mon, 13 Jun 2005 01:55:44 -0700
Received: from wproxy.gmail.com ([64.233.184.200])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DhkjP-0008D9-VK
	for nfs@lists.sourceforge.net; Mon, 13 Jun 2005 01:55:44 -0700
Received: by wproxy.gmail.com with SMTP id 69so934477wra
        for <nfs@lists.sourceforge.net>; Mon, 13 Jun 2005 01:55:43 -0700 (PDT)
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

Is it possible to set an NFS HA cluster?

That means, that several servers will share the same disks in a SAN and 
will provide an NFS service for

all my other servers?


I need that when one NFS server will fail (or the network connection to 
it)  then no server using the NFS will be affected and will continue to

work with one of the other NFS servers.


Is it possible?


Thanks,

Oded.




-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you shotput
a projector? How fast can you ride your desk chair down the office luge track?
If you want to score the big prize, get to know the little guy.  
Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
