From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS/TCP patches against 2.4.18 have problems
Date: 05 Jul 2002 14:41:28 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shspty2l53b.fsf@charged.uio.no>
References: <1025737993.1835.10.camel@plokta.s8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17QSP5-0007kt-00
	for <nfs@lists.sourceforge.net>; Fri, 05 Jul 2002 05:41:39 -0700
To: Bryan O'Sullivan <bos@serpentine.com>
In-Reply-To: <1025737993.1835.10.camel@plokta.s8.com>
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

>>>>> " " == Bryan O'Sullivan <bos@serpentine.com> writes:

     > Hi, Trond - I've been taking a look at the following patches
     > from your web site:

     >   linux-2.4.18-svc_tcp.dif.bz2 linux-2.4.18-rpc_tweaks.dif.bz2

     > In the accompanying commentary, you mention that the rpc_tweaks
     > patch applies on top of the svc_tcp patch, but this is not the
     > case.  I get two very substantial rejects, in net/sunrpc/xprt.c
     > and include/linux/sunrpc/xprt.h.

Yes. The rpc_tweaks patch also relies on some other changes. Most
notably, it assumes that the 'ping' patch (and possibly 'rpc_bkl')
have been applied...

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Bringing you mounds of caffeinated joy.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
