From: "David S. Miller" <davem@redhat.com>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.36
Date: Thu, 19 Sep 2002 14:12:43 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020919.141243.117916437.davem@redhat.com>
References: <3D89176B.40FFD09B@digeo.com>
	<20020919.221513.28808421.taka@valinux.co.jp>
	<3D8A36A5.846D806@digeo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: taka@valinux.co.jp, alan@lxorguk.ukuu.org.uk, neilb@cse.unsw.edu.au,
        linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pizda.ninka.net ([216.101.162.242])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17s8ki-0007Oa-00
	for <nfs@lists.sourceforge.net>; Thu, 19 Sep 2002 14:22:24 -0700
To: akpm@digeo.com
In-Reply-To: <3D8A36A5.846D806@digeo.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

   From: Andrew Morton <akpm@digeo.com>
   Date: Thu, 19 Sep 2002 13:42:13 -0700
   
   Mala's patch will cause quite an expansion
   of kernel size; we would need an implementation which did not
   use inlining.

It definitely belongs in arch/i386/lib/copy.c or whatever,
not inlined.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
