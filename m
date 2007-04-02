From: Toni Zimmer <T.Zimmer@science-computing.de>
Subject: Re: NFSv3-Client creates empty files on AIX 5.1/5.3 file
	server
Date: Mon, 2 Apr 2007 16:38:58 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0704021637420.1750@bender.science-computing.de>
References: <Pine.LNX.4.61.0703281442310.31576@bender.science-computing.de>
	<1175102015.6162.27.camel@heimdal.trondhjem.org>
	<Pine.LNX.4.61.0703291005150.31576@bender.science-computing.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HYNgb-0008VT-5X
	for nfs@lists.sourceforge.net; Mon, 02 Apr 2007 07:39:09 -0700
Received: from smtp2.belwue.de ([129.143.2.15])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HYNgb-00048L-0t
	for nfs@lists.sourceforge.net; Mon, 02 Apr 2007 07:39:11 -0700
Received: from mx3.science-computing.de (mx3.science-computing.de
	[193.197.16.20]) by smtp2.belwue.de with ESMTP id l32Ed3h4006639
	for <nfs@lists.sourceforge.net>; Mon, 2 Apr 2007 16:39:03 +0200 (MEST)
	env-from (T.Zimmer@science-computing.de)
Received: from localhost (localhost [127.0.0.1])
	by scmail.science-computing.de (Postfix) with ESMTP id 0230118048DF
	for <nfs@lists.sourceforge.net>; Mon,  2 Apr 2007 16:39:03 +0200 (CEST)
Received: from scmail.science-computing.de ([127.0.0.1])
	by localhost (guinesstest [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 32171-07 for <nfs@lists.sourceforge.net>;
	Mon, 2 Apr 2007 16:38:58 +0200 (CEST)
Received: from bender.science-computing.de (bender.science-computing.de
	[10.10.24.25])
	by scmail.science-computing.de (Postfix) with ESMTP id 6610818048DE
	for <nfs@lists.sourceforge.net>; Mon,  2 Apr 2007 16:38:58 +0200 (CEST)
Received: from localhost (localhost [127.0.0.1])
	by bender.science-computing.de (Postfix) with ESMTP id 5BFEA4128F27
	for <nfs@lists.sourceforge.net>; Mon,  2 Apr 2007 16:38:58 +0200 (CEST)
In-Reply-To: <Pine.LNX.4.61.0703291005150.31576@bender.science-computing.de>
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

Hi,

I called the IBM support and it seems to be an AIX issue. We're just 
waiting for the "efix"!

Greetings

Toni

Vorstand/Board of Management:
Dr. Bernd Finkbeiner, Dr. Florian Geyer,
Dr. Roland Niemeier, Dr. Arno Steitz, Dr. Ingrid Zech
Vorsitzender des Aufsichtsrats/
Chairman of the Supervisory Board:
Prof. Dr. Hanns Ruder
Sitz/Registered Office: Tuebingen
Registergericht/Registration Court: Stuttgart
Registernummer/Commercial Register No.: HRB 382196 


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
