From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] 2.6 open(O_EXCL) sets silly mtime
Date: Wed, 21 Apr 2004 10:17:57 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040421081757.GH16928@suse.de>
References: <20040420081822.GB14756@suse.de> <1082472473.3743.16.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BGCzV-0001k3-5m
	for nfs@lists.sourceforge.net; Wed, 21 Apr 2004 01:21:57 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BGCzU-0004SX-P8
	for nfs@lists.sourceforge.net; Wed, 21 Apr 2004 01:21:56 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1082472473.3743.16.camel@lade.trondhjem.org>
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

On Tue, Apr 20, 2004 at 10:47:53AM -0400, Trond Myklebust wrote:
> > the attached patch (relative to 2.6.5) is required to make sure a file
> > created with O_EXCL gets the proper mtime.
> 
> Well spotted. Should we also do the same for atime? AFAICS the server is
> allowed to trash that too.

If the spec says so, we should make sure atime gets set as well, yes.
I only fixed the mntime case because that's what the Linux nfsd clobbers.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
