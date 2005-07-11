From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH NFSv2] Drop inode after rename
Date: Mon, 11 Jul 2005 08:34:46 -0400
Message-ID: <1121085286.13326.2.camel@lade.trondhjem.org>
References: <20050711104611.GK27163@suse.de>
	 <1121079942.8204.15.camel@lade.trondhjem.org>
	 <20050711110733.GN27163@suse.de>
	 <1121080460.8204.18.camel@lade.trondhjem.org>
	 <20050711112431.GP27163@suse.de>
	 <1121082965.8204.42.camel@lade.trondhjem.org>
	 <20050711122818.GA19562@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DrxV0-00085p-5I
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 05:35:02 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1DrxUy-0004C9-Eq
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 05:35:02 -0700
To: Michael Schroeder <mls@suse.de>
In-Reply-To: <20050711122818.GA19562@suse.de>
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

m=C3=A5 den 11.07.2005 Klokka 14:28 (+0200) skreiv Michael Schroeder:

> AFAIR the problem is that i_nlink doesn't get decremented and
> therefore the inode doesn't get deleted.

OK. So how about just a one-liner _before_ the call to d_delete()? We
don't really care whether or not the rename was successful.

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
