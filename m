From: Olaf Kirch <okir@suse.de>
Subject: Re: RE: Race condition in xprt_disconnect
Date: Tue, 6 Apr 2004 16:26:49 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040406142649.GF29906@suse.de>
References: <1081197570.2641.133.camel@lade.trondhjem.org> <20040406092401.GA29906@suse.de> <1081260688.2846.30.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BArb1-0008Ur-H9
	for nfs@lists.sourceforge.net; Tue, 06 Apr 2004 07:30:35 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BAray-0002Xe-5V
	for nfs@lists.sourceforge.net; Tue, 06 Apr 2004 07:30:32 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1081260688.2846.30.camel@lade.trondhjem.org>
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

On Tue, Apr 06, 2004 at 10:11:29AM -0400, Trond Myklebust wrote:
> Can't tcp_state_change() inject a few more wakeups when we call
> xprt_close()?

I don't think I understand. tcp_state_change can't call xprt_close.

Or are you referring to your alternative patch that simply removed
the xprt_disconnect() from xprt_close? Yes, that would cure both
issues, too.

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
