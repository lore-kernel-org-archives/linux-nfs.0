From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] 2.6 open(O_EXCL) sets silly mtime
Date: Tue, 20 Apr 2004 10:47:53 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1082472473.3743.16.camel@lade.trondhjem.org>
References: <20040420081822.GB14756@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BFwXX-0000bk-KI
	for nfs@lists.sourceforge.net; Tue, 20 Apr 2004 07:47:59 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BFwXX-0008JM-8h
	for nfs@lists.sourceforge.net; Tue, 20 Apr 2004 07:47:59 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040420081822.GB14756@suse.de>
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

On Tue, 2004-04-20 at 04:18, Olaf Kirch wrote:
> Hi,
> 
> the attached patch (relative to 2.6.5) is required to make sure a file
> created with O_EXCL gets the proper mtime.

Well spotted. Should we also do the same for atime? AFAICS the server is
allowed to trash that too.

Hmm... Looking at the NFSv4 code, we really need to fix the same issues
up there too.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
