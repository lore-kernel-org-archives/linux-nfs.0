From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: RE: Race condition in xprt_disconnect
Date: Tue, 06 Apr 2004 10:36:10 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1081262170.2846.35.camel@lade.trondhjem.org>
References: <1081197570.2641.133.camel@lade.trondhjem.org>
	 <20040406092401.GA29906@suse.de>
	 <1081260688.2846.30.camel@lade.trondhjem.org>
	 <20040406142649.GF29906@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BArgS-0001SK-2e
	for nfs@lists.sourceforge.net; Tue, 06 Apr 2004 07:36:12 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BArgR-00042C-QQ
	for nfs@lists.sourceforge.net; Tue, 06 Apr 2004 07:36:11 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040406142649.GF29906@suse.de>
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

On Tue, 2004-04-06 at 10:26, Olaf Kirch wrote:
> On Tue, Apr 06, 2004 at 10:11:29AM -0400, Trond Myklebust wrote:
> > Can't tcp_state_change() inject a few more wakeups when we call
> > xprt_close()?
> 
> I don't think I understand. tcp_state_change can't call xprt_close.

No, but it does currently call xprt_disconnect().

I'm trying to work out whether or not the socket can change state again
after the server sends the FIN (or whatever it is it sends), but before
xprt_sock_connect()/keventd swaps out sk->state_change in its call to
xprt_close().

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
