Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:34992 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754380AbcK1TXo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 28 Nov 2016 14:23:44 -0500
Date: Mon, 28 Nov 2016 14:23:41 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: fix false positives in nfs40_walk_client_list()
Message-ID: <20161128192341.GB30954@fieldses.org>
References: <20161128140252.GA28629@fieldses.org>
 <de54b0ae-1345-beae-1e9f-efce39a75528@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <de54b0ae-1345-beae-1e9f-efce39a75528@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 28, 2016 at 01:46:00PM -0500, Anna Schumaker wrote:
> Hi Bruce,
> 
> On 11/28/2016 09:02 AM, J. Bruce Fields wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > It's possible that two different servers can return the same (clientid,
> > verifier) pair purely by coincidence.  Both are 64-bit values, but
> > depending on the server implementation, they can be highly predictable
> > and collisions may be quite likely, especially when there are lots of
> > servers.
> 
> How often have you been seeing this?

This was a RHEL customer bug originally, so somebody actually did run
across this in production, but I don't know how common that is.

On a recent client you'll only hit this if you mount with "migration",
so that's probably the main thing that prevents a lot of people from
running into it.

Given the "migration" mount option: if you have a client that mounts
multiple linux knfsd servers, you'll hit the bug whenever the mounts
occur within the same second, and the servers started within the same
second.  Both occurrences are fairly likely for example if you reboot
all your servers at once for maintenance.

But the bug should be much harder to hit against servers that have
already applied ebd7c72c63 "nfsd: randomize SETCLIENTID reply to help
distinguish servers".

Looking at SETCLIENTID replies at the recent bakeathon, I'm fairly
certain this could happen with other servers too.

The original bug is really in RFC 7931, which recommended the client
use a trunking-detection algorithm that made incorrect assumptions about
server behavior; see

	https://www.rfc-editor.org/errata_search.php?rfc=7931

The Linux client uses a much simpler algorithm than what's described
there, but it has the same fix.

> > +static bool nfs4_same_verifier(nfs4_verifier *v1, nfs4_verifier *v2)
> > +{
> > +	return 0 == memcmp(v1->data, v2->data, sizeof(v1->data));
> 
> Nit:  can you change the order to "memcmp() == 0"?

Sure, will you fix it up or should I resend?

--b.
