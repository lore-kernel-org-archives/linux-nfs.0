From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: clnt_max_conns ?
Date: Fri, 14 May 2004 16:23:27 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1084566207.4237.69.camel@lade.trondhjem.org>
References: <Pine.LNX.4.44.0405122206570.22744-100000@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BOjDN-0000Nk-2G
	for nfs@lists.sourceforge.net; Fri, 14 May 2004 13:23:29 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BOjDM-0001U2-Md
	for nfs@lists.sourceforge.net; Fri, 14 May 2004 13:23:28 -0700
To: Peter Astrand <peter@cendio.se>
In-Reply-To: <Pine.LNX.4.44.0405122206570.22744-100000@maggie.lkpg.cendio.se>
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

On Wed, 2004-05-12 at 16:11, Peter Astrand wrote:
> How many TCP connections are initiated by the Linux NFS client when using 
> TCP? Solaris, for example, seems to have a parameter called 
> "clnt_max_conns" that controls this. Is there anything similiar for Linux? 
> Does the number of TCP connections depend on the number of mounts?

1) 1 per mountpoint (except in the case of NFSv4 when it is 1 per
server).

2) Nope.

3) Yep. See (1).

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
