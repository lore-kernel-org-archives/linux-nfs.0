From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch] sunrpc: make closing of old temporary
	sockets	work (was: problems with lockd in 2.6.22.6)
Date: Wed, 12 Sep 2007 09:37:29 -0400
Message-ID: <20070912133729.GA24998@fieldses.org>
References: <200709121407.11151.wolfgang.walter@studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, trond.myklebust@fys.uio.no
To: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVSPd-0000NB-LR
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 06:37:50 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IVSPi-0001Cr-6l
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 06:37:54 -0700
In-Reply-To: <200709121407.11151.wolfgang.walter@studentenwerk.mhn.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, Sep 12, 2007 at 02:07:10PM +0200, Wolfgang Walter wrote:
> as already described old temporary sockets (client is gone) of lockd aren't
> closed after some time. So, with enough clients and some time gone, there
> are 80 open dangling sockets and you start getting messages of the form:
> 
> lockd: too many open TCP sockets, consider increasing the number of nfsd threads.

Thanks for working on this problem!

> If I understand the code then the intention was that the server closes
> temporary sockets after about 6 to 12 minutes:
> 
> 	a timer is started which calls svc_age_temp_sockets every 6 minutes.
> 
> 	svc_age_temp_sockets:
> 		if a socket is marked OLD it gets closed.
> 		sockets which are not marked as OLD are marked OLD
> 
> 	every time the sockets receives something OLD is cleared.
> 
> But svc_age_temp_sockets never closes any socket though because it only
> closes sockets with svsk->sk_inuse == 0. This seems to be a bug.
> 
> Here is a patch against 2.6.22.6 which changes the test to
> svsk->sk_inuse <= 0 which was probably meant. The patched kernel runs fine
> here. Unused sockets get closed (after 6 to 12 minutes)

So the fact that this changes the behavior means that sk_inuse is taking
on negative values.  This can't be right--how can something like
svc_sock_put() (which does an atomic_dec_and_test) work in that case?

I wish I had time today to figure out what's going on in this case.  But
from a quick through svsock.c for sk_inuse, it looks odd; I'm suspicious
of anything without the stereotyped behavior--initializing to one,
atomic_inc()ing whenever someone takes a reference, and
atomic_dec_and_test()ing whenever someone drops it....

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
