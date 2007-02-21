From: Bernd Schubert <bernd-schubert@gmx.de>
Subject: Re: mount problems - possibly 64bit
Date: Wed, 21 Feb 2007 13:25:37 +0100
Message-ID: <200702211325.37444.bernd-schubert@gmx.de>
References: <wolfgang-1070221123827.A0217144@noten5.maas-noten.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: wolfgang@noten5.maas-noten.de
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HJqXa-0004Aq-4v
	for nfs@lists.sourceforge.net; Wed, 21 Feb 2007 04:25:47 -0800
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HJqXb-0003sT-Nq
	for nfs@lists.sourceforge.net; Wed, 21 Feb 2007 04:25:48 -0800
In-Reply-To: <wolfgang-1070221123827.A0217144@noten5.maas-noten.de>
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

On Wednesday 21 February 2007 12:38, wolfgang@noten5.maas-noten.de wrote:
> I am trying to replace servers in an existing network by better ones
> (kernel 2.6.16 on amd 64bit) The server has
> nfs-server-2.2beta51-225.x86_64.rpm installed

Thats the userspace server, isn't it? Take the kernel server (or at least =

unfs3, if you really need a userspave daemon).


-- =

Bernd Schubert
PCI / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=3Djoin.php&p=3Dsourceforge&CID=3DDE=
VDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
