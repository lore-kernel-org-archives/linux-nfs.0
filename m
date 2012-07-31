Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36444 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753892Ab2GaOH4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jul 2012 10:07:56 -0400
Date: Tue, 31 Jul 2012 10:07:54 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: "ZUIDAM, Hans" <Hans.Zuidam@philips.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "DE WITTE, PETER" <PETER.DE.WITTE@philips.com>
Subject: Re: Linux NFS and cached properties
Message-ID: <20120731140754.GA27834@fieldses.org>
References: <D307B3AC0BCD4C419E6B8FA6A2720A9C0C3B2F@011-DB3MPN1-001.MGDPHG.emi.philips.com>
 <20120724143748.GC8570@fieldses.org>
 <D307B3AC0BCD4C419E6B8FA6A2720A9C18ABBA@011-DB3MPN1-001.MGDPHG.emi.philips.com>
 <20120726223607.GA28982@fieldses.org>
 <20120731150801.0a4b557b@notabene.brown>
 <20120731122546.GA26737@fieldses.org>
 <20120731124550.GA27135@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120731124550.GA27135@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 31, 2012 at 08:45:50AM -0400, J. Bruce Fields wrote:
> On Tue, Jul 31, 2012 at 08:25:46AM -0400, J. Bruce Fields wrote:
> > On Tue, Jul 31, 2012 at 03:08:01PM +1000, NeilBrown wrote:
> > > The idea of a new interface to synchronise with all threads has potential and
> > > doesn't need to be at the nfsd level - it could be in sunrpc.  Maybe it could
> > > be built into the current 'flush' interface.
> 
> The flush operation will have to know which services to wait on when
> flushing a given cache (lockd and nfsd in the export cache cases).
> 
> A little annoying that it may end up having to wait on a client-side
> operation in the case of lockd, but I don't think that's a show-stopper.

Ignore me, I wasn't thinking straight: a lockd thread won't of course be
waiting on client rpc's to a server, it will just be handling callbacks,
which should be very quick.

--b.
