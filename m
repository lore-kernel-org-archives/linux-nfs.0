From: Tiziano Zito <t.zito@biologie.hu-berlin.de>
Subject: NFS server hangs when user hits hard quota
Date: Wed, 7 Mar 2007 15:01:43 +0100
Message-ID: <20070307140143.GA20450@lotka.biologie.hu-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOwia-0007VO-Pz
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 06:02:12 -0800
Received: from suncom4.cms.hu-berlin.de ([141.20.1.74])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HOwib-00072E-Be
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 06:02:14 -0800
Received: from localhost (localhost [127.0.0.1])
	by suncom4.cms.hu-berlin.de (8.13.8/8.13.7) with ESMTP id
	l27E1lEX013337
	for <nfs@lists.sourceforge.net>; Wed, 7 Mar 2007 15:01:47 +0100 (CET)
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

Hi all! We are experiencing a problem with our nfs3 server
running a debian stable (sarge) kernel 2.4.32. 
When a program running on a client hits the user hard quota, the
server becomes really slow and almost unresponsive. This is easily
reproducible: on a client as a user with quota enabled do
cp /dev/zero /path/with/quota/enabled 
as soon as the user hits her/his hard limit the server chokes.
The only way to solve the problem is to disconnect the client from
the network and kill the offending process. 
I would think that such things should not happen, otherwise any user
could at anytime issue a DoS attack on the NFS server. I've seen
other posts relating to the same subject on this list:

http://thread.gmane.org/gmane.linux.nfs/159
http://thread.gmane.org/gmane.linux.nfs/216
http://thread.gmane.org/gmane.linux.nfs/2988
http://thread.gmane.org/gmane.linux.nfs/3938

What I can understand from this posts is that the problem was
present and that no solution existed, at least 3 years ago.
Is the situation in the meanwhile changed? Could a kernel upgrade or
an NFS3 -> NFS4 migration solve the problem?

Thank you very much for any response, at the moment we are really
stuck.

PS: please include me in the Cc, I'm not a subscriber of this list.


 Tiziano Zito
 Institute for Theoretical Biology
 Humboldt-Universitaet zu Berlin  
 Invalidenstrasse, 43
 D-10115 Berlin, Germany
 
 room: 1306
 phone: +49 30 2093-8630
 fax:   +49 30 2093-8801




-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
