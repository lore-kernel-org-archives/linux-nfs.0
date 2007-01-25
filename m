From: Bernd Schubert <bernd-schubert@gmx.de>
Subject: Re: Performance expectations of NFS
Date: Thu, 25 Jan 2007 23:50:21 +0100
Message-ID: <200701252350.22255.bernd-schubert@gmx.de>
References: <20070125193121.GA7267@anthem.async.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: Johan Dahlin <jdahlin@async.com.br>, nfs@lists.sourceforge.net
To: Undisclosed.Recipients: ;
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HADQP-0005kG-BM
	for nfs@lists.sourceforge.net; Thu, 25 Jan 2007 14:50:33 -0800
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HADQP-0004l8-5s
	for nfs@lists.sourceforge.net; Thu, 25 Jan 2007 14:50:35 -0800
In-Reply-To: <20070125193121.GA7267@anthem.async.com.br>
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

Hi Christian,

>   0:05  - Server: locally on RAID-5
>   0:06  - Client: copying from NFS mount to tmpfs
>   2:31  - Client: Copying from NFS mount to NFS mount
>           (i.e., the simple command above)
>   3:30  - Client: Copying from NFS mount to NFS mount over an existing
>           tree.
>   5:08  - Client: Copying from tmpfs to NFS mount
>   0:48  - Client: Deleting copy of tree on NFS mount

I guess your exports has the "sync" option or your didn't set  async or syn=
c =

at all (sync is then the default)? Can you repeat the test again using the =

async option? But please, also read carefully the explanations of "man 5 =

exports" about this topic. =


>
> Now I know that file creation is synchronous, and that because of this,
> the NFS copy will /always/ run significantly slower. But I was amazed at
> just how much faster reading was than writing, and at how fast reading
> actually is -- it's much faster than I expected NFS could be.

Just for fun, take ethereal and capture some data, once with the async and =

once with the sync option. Now have a look how much time each operation of =

the nfs client takes before it gets confirmed by the server. Especially loo=
k =

at the commit calls, once with sync and once with async option.

> But what I'd really like to know if there is a way of making the
> above operation run in significantly less time than it is today, or if

I guess if one could convince the nfs clients to reduce the number of commi=
t =

calls, write operations would be much much faster. Don't know if that is =

possible at all, though.


Cheers,
Bernd


-- =

Bernd Schubert
PCI / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=3Djoin.php&p=3Dsourceforge&CID=3DDE=
VDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
