From: Neil Brown <neilb@suse.de>
Subject: Does mountd/statd really need to listen on a privileged port??
Date: Fri, 13 Apr 2007 08:05:33 +1000
Message-ID: <17950.44333.118970.276558@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hc7QD-0004Nj-F7
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 15:05:42 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hc7QE-00058a-Kg
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 15:05:44 -0700
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 7D2A01241F
	for <nfs@lists.sourceforge.net>; Fri, 13 Apr 2007 00:05:38 +0200 (CEST)
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


mountd/statd currently bind to privileged ports to listen for
requests.

This is really a bad thing to do as there is no range of privilege
ports that is guaranteed not to be assigned to some service.

sm-notify probably still needs a privileged port to send out
notifications on, but that should be relatively short lived so
hopefully isn't as much of a problem.

statd needs a privileged port to pass NOTIFY requests down to the
kernel and that is probably the first really good reason I've seen to
replace the rpc interface between lockd and statd.

But if get mountd and statd to default to choosing a non-reserved port
for listening, that would at least decrease the chance that port 631
will be stolen before cupsd gets to bind it.

But is there some reason that mountd/statd need a priv port that I
haven't thought of?

Thanks,
NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
