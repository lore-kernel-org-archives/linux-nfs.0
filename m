From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Fix xprt_bindresvport
Date: Mon, 11 Jul 2005 08:13:36 -0400
Message-ID: <1121084016.8204.49.camel@lade.trondhjem.org>
References: <20050711092556.GD27163@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: nfs@lists.sourceforge.net, akpm@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DrxAW-00075f-Dd
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 05:13:52 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1DrxAV-0005iX-VT
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 05:13:52 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050711092556.GD27163@suse.de>
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

m=C3=A5 den 11.07.2005 Klokka 11:25 (+0200) skreiv Olaf Kirch:
> # Subject: Fix xprt_bindresvport
> #=20
> # xprt_bindresvport would grab ports in the range 1-800, which can
> # conflict with all sorts of network services. What we really want
> # to do is select from a range N - 1023.
> #=20
> # The patch below changes xprt_bindresvport to select ports from
> # 650-1023 by default (631 is cups, which we better avoid).
> # It also adds syscontrols to allow the admin to use a different
> # port range.

Yep. I'll try to fold this in for 2.6.14.

Note that when we're using RPCSEC_GSS, we ought to drop the reserved
port requirement altogether (and make sure that the server always
exports with the "insecure" option by default).

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
