From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH 0/8] nfsd4: keep the client from expiring while in use
	by nfs41 compounds
Date: Sun, 9 May 2010 12:55:52 -0400
Message-ID: <20100509165551.GA15429@fieldses.org>
References: <4BE0A1AE.4040905@panasas.com> <20100507223836.GO19142@fieldses.org> <4BE65687.8050806@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59688 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753727Ab0EIQzx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 May 2010 12:55:53 -0400
In-Reply-To: <4BE65687.8050806@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 09, 2010 at 09:30:31AM +0300, Benny Halevy wrote:
> Correct.  The intentions are:
> 1. Make the laundromat process ignore clients that are in
> use by a 4.1 session.
> 2. Renew the client when the compound ends, rather than when it begins.
> 3. Unhash the client when it's expired explicitly but don't destroy it
> until there's no reference to it.

OK.  My one slight worry there is to make sure that code getting a
pointer to a client through a sessionid won't inadvertently assume it's
still hashed.

By the way, the current stateid may present a similar problem to the
session, since it also lasts across compound ops and references a
client (and other state).

Looking through the code....  We don't implement the current stateid at
all yet.  Ouch.

I'll add that to the wiki.

> >> [PATCH 8/8] nfsd41: cstate->session can NULL in nfsd4_destroy_session
> >> I think this was introduced in: 26c0c75 nfsd4: fix unlikely race in session replay case
> >> though I'm not sure how it ever worked correctly...
> > 
> > Me neither.  I've got a similar patch in my tree.
> 
> Heh, I see.
> 5d4cec2 nfsd4: fix bare destroy_session null dereference

Apologies, I'd applied it privately but not pushed it out yet....  I
should have gotten that out faster.

--b.
