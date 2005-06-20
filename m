From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Exportfs and rpc.mountd optimalization
Date: Mon, 20 Jun 2005 14:19:06 -0400
Message-ID: <20050620181906.GD9639@fieldses.org>
References: <59a4169b050617155461156389@mail.gmail.com> <59a4169b05062010341629f27b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DkQrW-0005OP-Kn
	for nfs@lists.sourceforge.net; Mon, 20 Jun 2005 11:19:10 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DkQrU-0000I8-3B
	for nfs@lists.sourceforge.net; Mon, 20 Jun 2005 11:19:10 -0700
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

On Mon, Jun 20, 2005 at 07:34:38PM +0200, Tomas Richter wrote:
> I did some optimalization of exportfs and rpc.mountd (linked
> exportlist replaced by hash table). It has good results (I think) -
> computing of exportfs and mountd (after running exportfs) is quicker.
> Especially for long exportlists - about hundred thousand exports and
> more.

It'd be interesting to see whether you could reproduce (and improve on)
Vincent Rouqueta's results:

http://nfsv4.bullopensource.org/tools/tests/page17.php

> Can someone look on it?

Could you send your changes in the form of patches?  (See, e.g.,
http://www.zip.com.au/~akpm/linux/patches/stuff/tpp.txt).

--b.


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
