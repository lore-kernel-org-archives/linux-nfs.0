From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Reply-cache
Date: Mon, 11 Aug 2003 09:01:09 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16182.52917.693714.6285@gargle.gargle.HOWL>
References: <Pine.LNX.4.33.0308091522540.1062-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19lzBf-0004hb-00
	for <nfs@lists.sourceforge.net>; Sun, 10 Aug 2003 16:01:19 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <markhe@veritas.com>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Mon, 11 Aug 2003 09:01:09 +1000
To: Mark Hemment <markhe@veritas.com>
In-Reply-To: message from Mark Hemment on Saturday August 9
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Saturday August 9, markhe@veritas.com wrote:
>   A few NFS reply-cache questions, and possible answers.  Any feedback
> would be appreciated.
> 
> 1) Is a reply-cache needed over a reliable transport (TCP)?
>      Yes.  Possible for a client not to receive a response due to a
>    disconnect.  When re-connects, will retry the operation.  Need to trap
>    this.

Yes, technically it is needed, though practically it probably isn't of
any use.
When the client re-connects it will almost certainly use a different
port number, so the cache will treat it as a different source of
requests and will never find a re-transmitted request.

> 
> 2) Cache look-up before checking for a client's export entry?
>      The reply-cache look-up/resource-allocation occurs from
>    nfsd_dispatch() - before the exp_get() check in fh_verify().  This
>    allows for an attacker to fill the reply-cache with 'bogus' entries,
>    reducing it usefulness.  As NFS servers are either accessible only on
>    an intranet, or behind a firewall (unlikely?), this is not a serious
>    problem.
>       Partial fix is in nfsd_cache_lookup(), after checking 'type', test
>    if rq_client is NULL.   Not ideal, but will catch most cases.
>       Full fix is to move call to nfsd_cache_lookup() into fh_verify()
>    (and anywhere else needed(?)) after the exp_get_fsid()/exp_get().
>       If this is consider an issue, shout and I'll do a patch.

Probably the simplest thing to do is to not cache replies that return
STALE.  Any request from an unknown client will return ESTALE, and
there is no point caching that anyway (it is an idempotent reply).

> 
> 3) For non-idempotent operations, hold an "inprogress-entry" in the
>    reply-cache?
>       This would really only be for read operations, and possibly getattr,
>    over an unreliable transport (UDP).  On a 'busy' server, response
>    times may vary considerably; by trapping retransmitted requests which
>    are in-progress, the 'busy' server will not be further overloaded.
>    Note: I have no data to back this case up!  Does anyone have some
>    hard-data/references on this?
>       Ideally, the 'inprogress' entry would be dropped _after_ the
>    response has been sent.  With the current design, nfsd_dispatch() calls
>    nfsd_cache_update() before returning to the RPC code for a call to
>    svc_send().  A callback hook after svc_send() would be useful....
> 

Doest "RC_INPROG" work for you as an inprogress-entry?  If so, it is
already implemented.
But read operations and getaddr are idempotent, not non-idempotent, so
either you or I are a bit confused.

NeilBrown


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
