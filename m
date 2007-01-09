From: Adrian Phillips <a.phillips@met.no>
Subject: Re: nfs over ssh : invalid protocol
Date: Tue, 09 Jan 2007 06:55:59 +0100
Message-ID: <87ac0seob4.fsf@freeze.oslo.dnmi.no>
References: <36900.193.178.136.53.1168256160.squirrel@altern.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H49yQ-0000Fp-4n
	for nfs@lists.sourceforge.net; Mon, 08 Jan 2007 21:56:38 -0800
Received: from smtp1.oslo.dnmi.no ([128.39.62.241])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H49yQ-0000qN-KM
	for nfs@lists.sourceforge.net; Mon, 08 Jan 2007 21:56:40 -0800
Received: from freeze.oslo.dnmi.no ([157.249.16.34])
	by smtp1.oslo.dnmi.no with esmtp (Exim 4.50) id 1H49xn-00076v-9D
	for nfs@lists.sourceforge.net; Tue, 09 Jan 2007 05:55:59 +0000
Received: from tandem by freeze.oslo.dnmi.no with local (Exim 3.36 #1)
	id 1H49xn-0001gY-00
	for nfs@lists.sourceforge.net; Tue, 09 Jan 2007 05:55:59 +0000
To: nfs@lists.sourceforge.net
In-Reply-To: <36900.193.178.136.53.1168256160.squirrel@altern.org>
	(oudoubah@altern.org's
	message of "Mon, 8 Jan 2007 12:36:00 +0100 (CET)")
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

>>>>> "Oudoubah" == oudoubah  <oudoubah@altern.org> writes:

    Oudoubah> There is a firewall between the two servers, and only
    Oudoubah> the port 22 and 111 are open.

Try openvpn through one of these ports instead.

Sincerely,

Adrian Phillips

-- 
Who really wrote the works of William Shakespeare ?
http://www.pbs.org/wgbh/pages/frontline/shakespeare/

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
