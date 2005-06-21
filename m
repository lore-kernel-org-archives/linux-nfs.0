From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: Exportfs and rpc.mountd optimalization
Date: Tue, 21 Jun 2005 10:35:43 +0200
Message-ID: <200506211035.43497.vincent.roqueta@ext.bull.net>
References: <59a4169b050617155461156389@mail.gmail.com> <59a4169b05062010341629f27b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DkeA0-0005Iu-8f
	for nfs@lists.sourceforge.net; Tue, 21 Jun 2005 01:31:08 -0700
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Dke9x-0007Jc-FV
	for nfs@lists.sourceforge.net; Tue, 21 Jun 2005 01:31:08 -0700
To: nfs@lists.sourceforge.net, Tomas Richter <krik3t@gmail.com>
In-Reply-To: <59a4169b05062010341629f27b@mail.gmail.com>
Sender: nfs-admin@lists.sourceforge.net
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

Le lundi 20 Juin 2005 19:34, Tomas Richter a =E9crit=A0:
> I did some optimalization of exportfs and rpc.mountd (linked
> exportlist replaced by hash table). It has good results (I think) -
> computing of exportfs and mountd (after running exportfs) is quicker.
> Especially for long exportlists - about hundred thousand exports and
> more.
> Can someone look on it?
Yes! ;)


Vincent


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
