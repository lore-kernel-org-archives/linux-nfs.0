From: Denis Zaitsev <zzz@anda.ru>
Subject: statd question
Date: Thu, 25 Nov 2004 04:28:36 +0500
Message-ID: <20041125042836.A601@natasha.ward.six>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CX6Z7-0004JX-6B
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 15:28:49 -0800
Received: from [83.146.86.58] (helo=mail.ward.six)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CX6Z3-0002FV-Ha
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 15:28:47 -0800
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

man statd states:

    For each NFS client or server machine to be monitored, rpc.statd
    creates a file in /var/lib/nfs/sm.  When starting, it iterates
    through these files and notifies the peer rpc.statd on those
    machines.

A'm using nfs for a long time and I've never seen any file in
/var/lib/nfs/sm.  And I worry: is my nfs system feels ok?  Or maybe
something wrong with RPC?  Or maybe secure-statd configure option is
involved?  So what does this absence of the monitored hosts in the sm
dir mean?  NFS in general works well for me, afaik.

Thanks in advance.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
