From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: RE: Race condition in xprt_disconnect
Date: Tue, 06 Apr 2004 12:02:38 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1081267358.2921.3.camel@lade.trondhjem.org>
References: <1081197570.2641.133.camel@lade.trondhjem.org>
	 <20040406092401.GA29906@suse.de>
	 <1081260688.2846.30.camel@lade.trondhjem.org>
	 <20040406142649.GF29906@suse.de>
	 <1081262170.2846.35.camel@lade.trondhjem.org>
	 <1081263255.2846.50.camel@lade.trondhjem.org>
	 <20040406152303.GH29906@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BAt2A-0006mh-Jt
	for nfs@lists.sourceforge.net; Tue, 06 Apr 2004 09:02:42 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BAt2A-00039o-9Y
	for nfs@lists.sourceforge.net; Tue, 06 Apr 2004 09:02:42 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040406152303.GH29906@suse.de>
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

On Tue, 2004-04-06 at 11:23, Olaf Kirch wrote:

> Are you sure this helps? Your patch doesn't remove the xprt_disconnect
> call from xprt_close. This way, xprt_socket_connect still wakes
> up all tasks with ENOTCONN, triggering the connect worker to be
> scheduled a second time.

Oh, but I already have the xprt_disconnect() removal in a separate patch
which is applied *before* this one (see the patch I published in
response to yours last week).

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
