From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH 016 of 19] knfsd: match GRANTED_RES replies
	using	cookies
Date: Mon, 4 Sep 2006 11:09:39 +0200
Message-ID: <20060904090939.GC28400@suse.de>
References: <20060901141639.27206.patches@notabene>
	<1060901043932.27641@suse.de> <1157126618.5632.52.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>, Andrew Morton <akpm@osdl.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GKASc-0006jg-BP
	for nfs@lists.sourceforge.net; Mon, 04 Sep 2006 02:09:43 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GKASd-00065k-L1
	for nfs@lists.sourceforge.net; Mon, 04 Sep 2006 02:09:44 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1157126618.5632.52.camel@localhost>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, Sep 01, 2006 at 12:03:38PM -0400, Trond Myklebust wrote:
> Vetoed. The reason why we need the client's IP address as an argument
> for nlmsvc_find_block() is 'cos the cookie value is unique to the
> _client_ only.

In NLM, a cookie can be used to identify the asynchronous reply to the
original request. Previously, there was a hack in the code that
sends GRANT replies to reuse the original cookie from the client's
LOCK request. The protocol spec explicitly says you must not rely
on this behavior; the only reason I added this kludge was that some
HPUX and SunOS versions did just that.

The down side of that kludge is that we are using a client-provided cookie
in one of our calls - which means we keep our fingers crossed it doesn't
collide with the cookie we generate ourselves. And to reduce the risk,
we also check the client IP when searching the nlm_blocked list. But it
is incorrect, and a kludge, and the longer I look at this code the
more I'm amazed it hasn't blown up.

This patch changes the code so that the only cookies we ever use
to look up something are those we generate ourselves, so they
are globally unique. As a consequence, we can stop using the client's
IP when searching the list.

> IOW: when we go searching a global list of blocks for a given cookie
> value that was sent to us by a given client, then we want to know that
> we're only searching through that particular client's blocks.

This is no longer true after applying this change.

> A better way, BTW, would be to get rid of the global list nlm_blocked,
> and just move the list of blocks into a field in the nlm_host for each
> client.

Given an incoming NLM_GRANTED_RES, how can you look up the nlm_host
and the pending NLM_GRANTED_MSG?
The reply may not come from any IP address you know of. The whole
reason for introducing this cookie nonsense in the NLM specification
was that the RPC layer doesn't always give you enough clues to
match a callback to the original message.

So this is really a bugfix which you *do* want to apply.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
