From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] 2.4.19-pre10 RPC changes...
Date: Mon, 1 Jul 2002 14:16:29 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200207011416.29834.trond.myklebust@fys.uio.no>
References: <Pine.BSO.4.44.0206291443140.8167-100000@naughty.monkey.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17P06i-0008FH-00
	for <nfs@lists.sourceforge.net>; Mon, 01 Jul 2002 05:16:40 -0700
To: Chuck Lever <cel@monkey.org>
In-Reply-To: <Pine.BSO.4.44.0206291443140.8167-100000@naughty.monkey.org>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Saturday 29 June 2002 20:53, Chuck Lever wrote:
> hi trond-
>
> i'm able to deadlock my dual 1.26GHz P-III with just these patches applied
> to a naked 2.4.19-pre10 kernel:
>
> linux-2.4.19-00-fix_refresh.dif
> linux-2.4.19-01-fix_kmap1.dif
> linux-2.4.19-02-fix_kmap2.dif
> linux-2.4.19-03-fix_kmap3.dif

Any chance of finding out which one of the 3 kmap patches is the one giving 
trouble?

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
