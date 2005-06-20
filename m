From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Exportfs and rpc.mountd optimalization
Date: Mon, 20 Jun 2005 14:16:45 -0400
Message-ID: <1119291405.10757.33.camel@lade.trondhjem.org>
References: <59a4169b050617155461156389@mail.gmail.com>
	 <59a4169b05062010341629f27b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DkQpR-0005HM-0e
	for nfs@lists.sourceforge.net; Mon, 20 Jun 2005 11:17:01 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DkQpQ-0001DP-C3
	for nfs@lists.sourceforge.net; Mon, 20 Jun 2005 11:17:00 -0700
To: Tomas Richter <krik3t@gmail.com>
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

m=C3=A5 den 20.06.2005 Klokka 19:34 (+0200) skreiv Tomas Richter:
> I did some optimalization of exportfs and rpc.mountd (linked
> exportlist replaced by hash table). It has good results (I think) -
> computing of exportfs and mountd (after running exportfs) is quicker.
> Especially for long exportlists - about hundred thousand exports and
> more.
> Can someone look on it?

If you would like to propose changes to the nfs-utils package, then
please repost them in the form of a standard patch against the current
nfs-utils CVS tree (see http://sourceforge.net/projects/nfs) so that
they may be reviewed.

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
