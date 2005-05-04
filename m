From: Benjamin Jeeves <benjamin@benjamin76.plus.com>
Subject: Help needed
Date: Wed, 4 May 2005 12:06:20 +0100
Message-ID: <200505041206.20407.benjamin@benjamin76.plus.com>
Reply-To: benjamin@benjamin76.plus.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DTHkF-0004Vg-10
	for nfs@lists.sourceforge.net; Wed, 04 May 2005 04:08:47 -0700
Received: from ptb-relay03.plus.net ([212.159.14.214])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DTHkC-0004Y8-JK
	for nfs@lists.sourceforge.net; Wed, 04 May 2005 04:08:46 -0700
Received: from [80.229.196.83] (helo=deve-box.thelab)
	 by ptb-relay03.plus.net with esmtp (Exim) id 1DTHk5-0007Ab-OU
	for nfs@lists.sourceforge.net; Wed, 04 May 2005 12:08:37 +0100
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

Hi all

This is the first time posting to this list so please understand if this 
quistion has been posted before.

I have one server with 4 ethernet card in all running on 192.168.1.* network 
what i want to do is run nfs on.

eth2 192.168.1.6 running nfs
eth3 192.168.1.7 running nfs

eth2 would export samething like this /backup then /store.

eth3 would export samething like this /folder3 /folder4

but at this time all I can do is make it work on all of the ethernet cards and 
only work on the first ethernet card eth0 for all requests.

I have search gooogle and man pages but can not find anything or would I need 
to do load balancing for this to work?

I have tryed this in the /etc/exports file:
192.168.1.6:/backup	192.168.1.12(rw,root_squash,sync)
192.168.1.6:/store	192.168.1.12(rw,root_squash,sync)
192.168.1.7:/folder3	192.168.1.14(rw,root_squash,sync)
192.168.1.7:/folder4	192.168.1.14(rw,root_squash,sync)

#mount 192.168.1.6:/mad-backup /backup

But when i try to mount it on the client I get a this msg
mount: 192.168.1.6:/backup failed, reason given by server: Permission denied

please help me?

Thank you

Benjamin Jeeves 



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
