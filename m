From: Olaf Kirch <okir@suse.de>
Subject: Re: RE: Race condition in xprt_disconnect
Date: Tue, 6 Apr 2004 17:23:03 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040406152303.GH29906@suse.de>
References: <1081197570.2641.133.camel@lade.trondhjem.org> <20040406092401.GA29906@suse.de> <1081260688.2846.30.camel@lade.trondhjem.org> <20040406142649.GF29906@suse.de> <1081262170.2846.35.camel@lade.trondhjem.org> <1081263255.2846.50.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BAsPq-0004yJ-Ua
	for nfs@lists.sourceforge.net; Tue, 06 Apr 2004 08:23:06 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BAsPq-00076o-Jx
	for nfs@lists.sourceforge.net; Tue, 06 Apr 2004 08:23:06 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1081263255.2846.50.camel@lade.trondhjem.org>
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

On Tue, Apr 06, 2004 at 10:54:15AM -0400, Trond Myklebust wrote:
> The policy should be that once tcp_state_change() clears the "connected"
> bit, and has woken up those requests that were waiting on a reply, it
> should just stay out of the way. We do not want it to interfere with the
> reconnection process (the task timeouts etc should suffice for error
> handling). This patch should ensure that is the case.

Are you sure this helps? Your patch doesn't remove the xprt_disconnect
call from xprt_close. This way, xprt_socket_connect still wakes
up all tasks with ENOTCONN, triggering the connect worker to be
scheduled a second time.

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
