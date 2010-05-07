From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH 0/8] nfsd4: keep the client from expiring while in use
	by nfs41 compounds
Date: Fri, 7 May 2010 18:38:36 -0400
Message-ID: <20100507223836.GO19142@fieldses.org>
References: <4BE0A1AE.4040905@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53781 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751504Ab0EGWig (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 May 2010 18:38:36 -0400
In-Reply-To: <4BE0A1AE.4040905@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 05, 2010 at 01:37:34AM +0300, Benny Halevy wrote:
> Bruce,
> 
> The following patchset changes the scope of the sessionid spin lock
> to cover both sessions and the client lru list and it introduces a
> new reference count on the client that's manipulated under that new
> client lock (not requiring the state mutex).
> 
> It's tested to pass connectathon tests as well as explicit session destroy
> and implicit client expiry when the client is blown away.
> However, I haven't tested the gist of this patchset which is to get
> the client to perform a long enough compound during which it might time out...

Yeah, I'm not sure how to test that.  Create a temporary patch
introducign a "delay X seconds" compound op, then teach pynfs to send
those timed to coincide with client-reboot exchangeid's or the end of a
client lease?

So if I understand the intention of these patches right: behavior in the
case of something explicitly destroys a client (e.g. client-rebooting
exchangeid) is to partially destroy the client, but allow any concurrent
compound to attempt to continue processing with the near-dead client?

> [PATCH 1/8] nfsd4: rename sessionid_lock to client_lock
> [PATCH 2/8] nfsd4: fold release_session into expire_client
> [PATCH 3/8] nfsd4: use list_move in move_to_confirmed
> [PATCH 4/8] nfsd4: extend the client_lock to cover cl_lru
> [PATCH 5/8] nfsd4: refactor expire_client
> [PATCH 6/8] nfsd4: introduce nfs4_client.cl_refcount
> [PATCH 7/8] nfsd4: keep a reference count on client while in use
> 
> [PATCH 8/8] nfsd41: cstate->session can NULL in nfsd4_destroy_session
> I think this was introduced in: 26c0c75 nfsd4: fix unlikely race in session replay case
> though I'm not sure how it ever worked correctly...

Me neither.  I've got a similar patch in my tree.

--b.
