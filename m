From: Bryan O'Sullivan <bos@serpentine.com>
Subject: Re: NFS/TCP patches against 2.4.18 have problems
Date: 05 Jul 2002 12:38:05 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1025897885.10934.67.camel@plokta.s8.com>
References: <1025737993.1835.10.camel@plokta.s8.com>
	<shspty2l53b.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from server.s8.com ([66.77.12.139])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17QYuB-0008V8-00
	for <nfs@lists.sourceforge.net>; Fri, 05 Jul 2002 12:38:11 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shspty2l53b.fsf@charged.uio.no>
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

On Fri, 2002-07-05 at 05:41, Trond Myklebust wrote:

> Yes. The rpc_tweaks patch also relies on some other changes. Most
> notably, it assumes that the 'ping' patch (and possibly 'rpc_bkl')
> have been applied...

Thanks, that made a difference.  Might be worth stating explicitly on
the web page, though :-)

By the way, the fattr patch that the BKL removal patch depends on does
not appear to exist.

	<b


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Bringing you mounds of caffeinated joy.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
