Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51268 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753630Ab3GIPEg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jul 2013 11:04:36 -0400
Date: Tue, 9 Jul 2013 11:04:28 -0400
To: NeilBrown <neilb@suse.de>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH - RFC]  new "nosharetransport" option for NFS mounts.
Message-ID: <20130709150428.GA8281@fieldses.org>
References: <20130708095812.355d7cfc@notabene.brown>
 <1373309499.2231.46.camel@leira.trondhjem.org>
 <20130709132253.3dd4f90a@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130709132253.3dd4f90a@notabene.brown>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 09, 2013 at 01:22:53PM +1000, NeilBrown wrote:
> On Mon, 8 Jul 2013 18:51:40 +0000 "Myklebust, Trond"
> <Trond.Myklebust@netapp.com> wrote:
> 
> > On Mon, 2013-07-08 at 09:58 +1000, NeilBrown wrote:
> > > 
> > > This patch adds a "nosharetransport" option to allow two different
> > > mounts from the same server to use different transports.
> > > If the mounts use NFSv4, or are of the same filesystem, then
> > > "nosharecache" must be used as well.
> > 
> > Won't this interfere with the recently added NFSv4 trunking detection?
> 
> Will it?  I googled around a bit but couldn't find anything that tells me
> what trunking really was in this context.  Then I found commit 05f4c350ee02 
> which makes it quite clear (thanks Chuck!).
> 
> Probably the code I wrote could interfere.
> 
> > 
> > Also, how will it work with NFSv4.1 sessions? The server will usually
> > require a BIND_CONN_TO_SESSION when new TCP connections attempt to
> > attach to an existing session.

Since the current client only requests SP4_NONE state protection, the
BIND_CONN_TO_SESSION is implicit:

	If, when the client ID was created, the client opted for
	SP4_NONE state protection, the client is not required to use
	BIND_CONN_TO_SESSION to associate the connection with the
	session, unless the client wishes to associate the connection
	with the backchannel.  When SP4_NONE protection is used, simply
	sending a COMPOUND request with a SEQUENCE operation is
	sufficient to associate the connection with the session
	specified in SEQUENCE.

But Neil would need to make sure he's using all the state associated
with the existing client.

> Why would it attempt to attach to an existing session?  I would hope there
> the two different mounts with separate TCP connections would look completely
> separate - different transport, different cache, different session.
> ??

Sounds to me sharing these things shouldn't be a problem in your case,
but I don't know.

--b.
