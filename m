From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH][RFC] Multiple UDP sockets for knfsd
Date: Sat, 15 May 2004 13:22:03 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1084641723.3490.13.camel@lade.trondhjem.org>
References: <40A42DB8.7B9C8152@melbourne.sgi.com>
	 <1084566110.4237.66.camel@lade.trondhjem.org>
	 <20040515063854.GB14983@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg Banks <gnb@melbourne.sgi.com>, Neil Brown <neilb@cse.unsw.edu.au>,  Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BP2rS-0003KN-6V
	for nfs@lists.sourceforge.net; Sat, 15 May 2004 10:22:10 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BP2rR-00077n-Re
	for nfs@lists.sourceforge.net; Sat, 15 May 2004 10:22:09 -0700
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20040515063854.GB14983@sgi.com>
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

On Sat, 2004-05-15 at 02:38, Greg Banks wrote:
> On Fri, May 14, 2004 at 04:21:50PM -0400, Trond Myklebust wrote:
> > 
> > I'm confused here. Are you actually implying that socket contention is
> > responsible for a full *40%* decrease in throughput?
> 
> At that level of throughput, yes.

So what exactly *is* this bottleneck? As far as we're concerned, a
socket is basically just a buffer and a couple of locks.

IOW, are you seeing actual lock contention here, or could we just obtain
the same effect by bumping the send or receive buffer size on the
existing UDP socket?

If you are indeed seeing lock contention, then exactly which lock are we
talking about? Is it spinning on sending the reply, is it the receive
softirq, or is it one of those RPC svcsock-specific locks?

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
