From: "Howie Xu" <howie@vmware.com>
Subject: RE: How to unlock a file if an NFSv3 client dies forever?
Date: Wed, 26 May 2004 13:27:06 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4F28105F70F4324A8723F0C949088941BCB774@pa-exch5.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BT4zU-0005xT-MG
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 13:27:08 -0700
Received: from mailout1.vmware.com ([65.113.40.130])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BT4zU-0007KY-Aj
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 13:27:08 -0700
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
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


> it seems i had some luck at some point with this approach:
>=20
>   mv dead_locked_file /tmp/dead_locked_file && mv=20
> /tmp/dead_locked_file dead_locked_file

Yeah, there are a couple of other workarounds too. But my very question =
is
that how to solve this problem in the design/protcocol level now that I =
am
starting a project from the scratch. I don't want to ship an nfs client =
with
this catch in it.:)

Maybe NFSv4 solved this problem in the protocol already?

Thanks again,

-howie


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
