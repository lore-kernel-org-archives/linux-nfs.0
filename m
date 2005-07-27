From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Kernel 2.6 vs. Kernel 2.4: higher NFS traffic
Date: Tue, 26 Jul 2005 20:46:03 -0400
Message-ID: <1122425163.23486.8.camel@lade.trondhjem.org>
References: <20050726093038.FD8E.BRANDEN@terra.com.br>
	 <20050726201432.22AA.BRANDEN@terra.com.br>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dxa51-0007UA-Ow
	for nfs@lists.sourceforge.net; Tue, 26 Jul 2005 17:47:27 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Dxa50-0002Nf-G2
	for nfs@lists.sourceforge.net; Tue, 26 Jul 2005 17:47:27 -0700
To: Filipe Brandenburger <branden@terra.com.br>
In-Reply-To: <20050726201432.22AA.BRANDEN@terra.com.br>
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

ty den 26.07.2005 Klokka 20:18 (-0300) skreiv Filipe Brandenburger:

> Is there a way to disable this behaviour? To disable the ACCESS calls
> for non-root users on kernel 2.6? I run all my applications as non-root
> user, and one of the reasons for that is the lots of RPC calls to
> v3access that begun to appear when upgrading from NFSv2 to NFSv3, so
> that I actually see this behaviour on 2.6 a little as a negative factor
> for upgrading from 2.4 to 2.6...

There were a couple of kernels in the mid-2.6 series where the caching
didn't work too well. More recent kernels should be fine, though.

There are no plans to allow users to disable ACCESS checking, however
there are places where the access calls may be optimised away (I think
I've done it for most of them now).

The main optimisation that remains is in the open() codepath, where we
currently do a GETATTR, then ACCESS. In the case where the server
supports post-op attributes on ACCESS, then that case can be reduced to
a single call to ACCESS (i.e. we get rid of the GETATTR call).

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
