From: raini-9HxftnAiGddWk0Htik3J/w@public.gmane.org
Subject: Re: [NFS] NFS/krb and batch jobs - doable?
Date: Fri, 9 Oct 2009 09:53:51 -0700
Message-ID: <1c358fde92c49215d84129a1bfe2c6ec.squirrel@webmail.rainiday.com>
References: <c8e974302190b867ad8ea49d8158f1db.squirrel@webmail.rainiday.com>
    <20091009121602.5ec86dfb@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from caiajhbihbdd.dreamhost.com ([208.97.187.133]:43726 "EHLO
	webmail2.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751971AbZJIRDT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Oct 2009 13:03:19 -0400
Received: from webmail.rainiday.com (localhost [127.0.0.1])
	by webmail2.g.dreamhost.com (Postfix) with ESMTP id 3C42DDC8A1
	for <linux-nfs@vger.kernel.org>; Fri,  9 Oct 2009 09:53:51 -0700 (PDT)
In-Reply-To: <20091009121602.5ec86dfb-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> No, gssd (the client side daemon) will search /tmp for anything that
> looks like a credcache for the right user, verify that it is a
> credcache and then pick the one with the latest TGT expiration.

> You're correct that NFS ignores $KRB5CCNAME. It uses the above (less
> than optimal) heuristic instead.

Thanks for explaining this Jeff - this does accord with what I see - which
of course leaves my batch job system unpredictable.

> Probably doable, but not trivial. IIRC, the kernel tracks credentials
> by uid. You'd need to determine some way to split that up so that each
> "session" has separate credentials. Once you do that, you'll have to
> have the kernel pass enough info to the upcall for it to determine what
> credcache it should use and modify gssd to use the new info accordingly.

Just to be clear - you mean doable to a coder who might like to improve on
gssd/kernel credential separation, rather than a non-coding sysadmin who
needs with work within the current NFS/gssd framework?

