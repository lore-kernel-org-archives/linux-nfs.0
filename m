From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: Re: [PATCH - try #2] sunrpc: fix typo in svc_udp_recvfrom
Date: Wed, 28 Mar 2007 13:41:49 +0200
Message-ID: <200703281341.50102.olaf.kirch@oracle.com>
References: <200703271651.13181.olaf.kirch@oracle.com>
	<200703280751.22646.olaf.kirch@oracle.com>
	<17930.17312.372279.748098@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWYZe-0001VB-FT
	for nfs@lists.sourceforge.net; Wed, 28 Mar 2007 06:52:26 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HWYZe-0002oR-Iy
	for nfs@lists.sourceforge.net; Wed, 28 Mar 2007 06:52:28 -0700
Received: from rgmgw2.us.oracle.com (rgmgw2.us.oracle.com [138.1.186.111])
	by rgminet01.oracle.com (Switch-3.2.4/Switch-3.1.6) with ESMTP id
	l2SDO2s9015470
	for <nfs@lists.sourceforge.net>; Wed, 28 Mar 2007 07:52:15 -0600
Received: from acsmt350.oracle.com (acsmt350.oracle.com [141.146.40.150])
	by rgmgw2.us.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id
	l2SADw7d017687
	for <nfs@lists.sourceforge.net>; Wed, 28 Mar 2007 05:43:37 -0600
In-Reply-To: <17930.17312.372279.748098@notabene.brown>
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

On Wednesday 28 March 2007 12:29, Neil Brown wrote:

> > > +	if (skb == NULL) {
> > > +		if (err != -EAGAIN) {
> > > +			/* possibly an icmp error */
> > > +			dprintk("svc: recvfrom returned error %d\n", -err);
> > > +			set_bit(SK_DATA, &svsk->sk_flags);
>                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


Okay, you're right - I missed that.

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
