From: Olaf Kirch <okir@suse.de>
Subject: Re: 2.6.5-rc3 xprt_connect changes?
Date: Fri, 2 Apr 2004 10:27:15 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040402082715.GD11477@suse.de>
References: <20040401144740.GH20772@suse.de> <1080853027.2682.22.camel@lade.trondhjem.org> <1080854329.2682.36.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B9K1I-0004ZL-1K
	for nfs@lists.sourceforge.net; Fri, 02 Apr 2004 00:27:20 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B9K1G-0004cW-6L
	for nfs@lists.sourceforge.net; Fri, 02 Apr 2004 00:27:18 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1080854329.2682.36.camel@lade.trondhjem.org>
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

On Thu, Apr 01, 2004 at 04:18:49PM -0500, Trond Myklebust wrote:
> On Thu, 2004-04-01 at 15:57, Trond Myklebust wrote:
> 
> > How about if we simply move the call for xprt_disconnect() out of
> > xprt_close()?
> 
> IOW, something like the appended patch. (Note the change to ensure that
> we *do* wake up all pending tasks if the current attempt at reconnecting
> actually fails.)

Yes, this patch should do the same, and it's nicer.

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
