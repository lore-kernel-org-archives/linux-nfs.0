From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH][RFC] Multiple UDP sockets for knfsd
Date: Fri, 14 May 2004 16:21:50 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1084566110.4237.66.camel@lade.trondhjem.org>
References: <40A42DB8.7B9C8152@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Brown <neilb@cse.unsw.edu.au>, Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BOjBw-00005j-JI
	for nfs@lists.sourceforge.net; Fri, 14 May 2004 13:22:00 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BOjBw-0001Dg-96
	for nfs@lists.sourceforge.net; Fri, 14 May 2004 13:22:00 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <40A42DB8.7B9C8152@melbourne.sgi.com>
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

On Thu, 2004-05-13 at 22:23, Greg Banks wrote:
> G'day,
> 
> This patch attempts to implement a suggestion made by Neil Brown in
> offline discussions, to extend the Linux NFS server to use multiple
> UDP sockets for load sharing.  It turns out that the single UDP socket
> is a throughput limiter at surprisingly small loads.  With this patch
> my test machine goes from being limited at about 146 MB/s in cached
> read loads over UDP to about 210~230 MB/s, which is about the same
> number as the same test over TCP.

Greg,

I'm confused here. Are you actually implying that socket contention is
responsible for a full *40%* decrease in throughput? If not, please
could you explain which bottleneck this patch is removing?

Also, isn't that call to sock_release() while holding serv->sv_lock a
tad deadlock-prone? Note that sock_release() will call bh_lock_sock()...

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
