From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH]  Reinstantiating stale inodes
Date: Mon, 03 May 2004 16:15:38 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1083615338.3896.92.camel@lade.trondhjem.org>
References: <40892507.2030004@RedHat.com>  <4093CCB6.1040500@RedHat.com>
	 <1083439518.3687.19.camel@lade.trondhjem.org> <4094397C.3030303@RedHat.com>
	 <1083457337.3687.60.camel@lade.trondhjem.org> <409468B2.40200@RedHat.com>
	 <1083468517.3687.70.camel@lade.trondhjem.org> <4096A292.8050109@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BKjrI-0006It-J9
	for nfs@lists.sourceforge.net; Mon, 03 May 2004 13:16:12 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BKjqo-0007v1-1w
	for nfs@lists.sourceforge.net; Mon, 03 May 2004 13:15:42 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <4096A292.8050109@RedHat.com>
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

On Mon, 2004-05-03 at 15:50, Steve Dickson wrote:

> So I would like to propose a less intrusive patch what will simply zap
> the directories caches when nfs_revalidate() sees an ESTALE.
> 
> This patch does not effect traffic and only the first dir entry is 
> failed with ESTALE
> and finally subsequent ls will not fail with ESTALEs....
> 
> Comments?

That one looks fine (although it will not apply to 2.6.x).

I'm still curious to find out which operations are changing ctime on the
parent directory without changing mtime, though.

I've identified only two more (beside utime()), so far: link()/unlink()
change the ctime on the file but both do set mtime and ctime on the
parent directory.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
