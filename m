From: "Howie Xu" <howie@vmware.com>
Subject: RE: Activate NFS over TCP (2.4.20)
Date: Wed, 26 May 2004 00:04:07 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4F28105F70F4324A8723F0C949088941C29A35@pa-exch5.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BSsSS-000232-FE
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 00:04:12 -0700
Received: from mailout1.vmware.com ([65.113.40.130])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BSsSR-000654-TQ
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 00:04:11 -0700
Received: from mailout1.vmware.com (mailout1.vmware.com [127.0.0.1])
	by mailout1.vmware.com (Postfix) with ESMTP id A21CD44AF
	for <nfs@lists.sourceforge.net>; Wed, 26 May 2004 00:04:10 -0700 (PDT)
Received: from mailhost1.vmware.com (mailhost1.vmware.com [10.16.12.135])
	by mailout1.vmware.com (Postfix) with ESMTP id 4A2FA44AF
	for <nfs@lists.sourceforge.net>; Wed, 26 May 2004 00:04:10 -0700 (PDT)
Received: from localhost (localhost [127.0.0.1])
	by mailhost1.vmware.com (Postfix) with ESMTP id B2FB36FC342
	for <nfs@lists.sourceforge.net>; Wed, 26 May 2004 00:04:16 -0700 (PDT)
Received: from pa-exch3.vmware.com (pa-exch3.vmware.com [10.16.15.61])
	by mailhost1.vmware.com (Postfix) with ESMTP id 291566FC341
	for <nfs@lists.sourceforge.net>; Wed, 26 May 2004 00:04:15 -0700 (PDT)
To: <bondalapati@excite.com>, <nfs@lists.sourceforge.net>
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

You need to build your own kernel that has the NFS over TCP option on. =
It is
not there by default.
=20
-howie

	-----Original Message-----=20
	From: Raghuram bondalapati [mailto:bondalapati@excite.com]=20
	Sent: Tue 5/25/2004 11:15 PM=20
	To: nfs@lists.sourceforge.net=20
	Cc:=20
	Subject: [NFS] Activate NFS over TCP (2.4.20)
=09
=09
I have recently build my linux box with 2.4.20 kernel which I use it as =
a NFS
server.
I would like to know how i can activate NFS over TCP. By deafult the =
nfsd is
serving for udp and i have found documentation in nfs.sourceforge.net =
which
suggests that NFS over TCP is possible for 2.419 and above kernels.

Thanks
--Raghu




=09

=09
  _____ =20

	Join Excite! - http://www.excite.com
	The most personalized portal on the Web!=20



-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
