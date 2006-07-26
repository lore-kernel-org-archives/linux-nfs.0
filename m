From: "Michael Han" <mhan@postini.com>
Subject: default sunrpc.min_resvport
Date: Wed, 26 Jul 2006 10:16:27 -0700
Message-ID: <168996D6C4DFA945B032B63C0DEAA6BF0421E687@EXCHANGE1.postini.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G6I0i-0006er-By
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 19:23:33 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G64ha-0001al-V3
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 05:10:58 -0700
Received: from exprod8og50.obsmtp.com ([64.18.3.82])
	by externalmx-1.sourceforge.net with smtp (TLSv1:AES256-SHA:256)
	(Exim 4.41) id 1G60I7-0007ec-OT
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 00:28:20 -0700
Received: from exchsrvr3.postini.com (exchsrvr3.postini.com [172.16.0.56])
	by thor.postinicorp.com (Postfix) with ESMTP id AE62F178B49
	for <nfs@lists.sourceforge.net>; Wed, 26 Jul 2006 10:16:31 -0700 (PDT)
To: <nfs@lists.sourceforge.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

I'm not sure if this has surfaced before for discussion (searching
hasn't shown me any relevant threads), but the 2.6 kernel's new
implementation of xprt_bindresvport can conflict with port 664 on
IPMI-enabled hosts with a BMC. IPMI uses both ports 623 and 664 for
communications, and several implementations appear to intercept all
traffic for these ports and not permit them to pass to the standard
packet driver (tcpdump in promiscuous mode shows no packets coming in).

I know that in the discussions back in 2005/02 and 2005/07 of the patch
that implements the new privileged port binding for NFS mount (I can't
tell whose patch it is, perhaps Olaf Kirch's?), Charles Lever noted that
the new sunrpc.min_resvport of 650 avoids conflicts with port 623. Is it
worth increasing this default to 665 to avoid this port as well?

If not, I just wanted to get this information onto the list, since I
searched pretty heavily while researching the intermittent hangs I've
been getting with my NFS mounts before finally nailing this to my IPMI
BMCs. Manually setting sunrpc.min_resvport to 700 has stabilized NFS on
my boxes. Thanks.

Michael Han
mhan@postini.com






-----------------------------------------------------------
This message may contain confidential and/or privileged 
information. This information is intended to be read only
by the individual or entity to whom it is addressed. If
you are not the intended recipient, you are on notice that
any review, disclosure, copying, distribution or use of
the contents of this message is strictly prohibited. If
you have received this message in error, please notify the
sender immediately and delete or destroy any copy of this
message.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
