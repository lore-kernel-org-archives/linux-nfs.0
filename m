From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] zerocopy NFS for 2.5.36
Date: 19 Sep 2002 11:42:43 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1032432163.26669.16.camel@irongate.swansea.linux.org.uk>
References: <20020918.160057.17194839.davem@redhat.com>
	<1032393277.24895.8.camel@irongate.swansea.linux.org.uk>
	<3D89176B.40FFD09B@digeo.com> <20020919021333.GC20500@vitelus.com>
	<3D8944EC.D129579D@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Aaron Lehmann <aaronl@vitelus.com>, linux-kernel@vger.kernel.org,
   nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pc1-cwma1-5-cust128.swa.cable.ntl.com ([80.5.120.128] helo=irongate.swansea.linux.org.uk)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ryhZ-0000r7-00
	for <nfs@lists.sourceforge.net>; Thu, 19 Sep 2002 03:38:29 -0700
To: Andrew Morton <akpm@digeo.com>
In-Reply-To: <3D8944EC.D129579D@digeo.com>
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

On Thu, 2002-09-19 at 04:30, Andrew Morton wrote:
> > It's disappointing that this program doesn't seem to support
> > benchmarking of MMX copy loops (like the ones in arch/i386/lib/mmx.c).
> > Those seem to be the more interesting memcpy functions on modern
> > systems.
> 
> Well the source is there, and the licensing terms are most reasonable.
> 
> But then, the source was there eighteen months ago and nothing happened.
> Sigh.
> 
> I think in-kernel MMX has fatal drawbacks anyway.  Not sure what
> they are - I prefer to pretend that x86 CPUs execute raw C.

MMX isnt useful for anything smaller than about 512bytes-1K. Its not
useful in interrupt handlers. The list goes on.



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
