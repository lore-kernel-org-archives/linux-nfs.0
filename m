Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27099 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756812Ab0LPRfh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Dec 2010 12:35:37 -0500
Subject: Re: [PATCH 1/9] Revert "pnfs-submit: wave2: remove forgotten
 layoutreturn struct definitions"
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <4D0A3D44.2000101@panasas.com>
References: <4D0908F9.4060208@panasas.com>
	 <1292437854-21651-1-git-send-email-bhalevy@panasas.com>
	 <1292437973.3068.15.camel@heimdal.trondhjem.org>
	 <4D090E18.4060205@panasas.com>
	 <1292441468.3068.53.camel@heimdal.trondhjem.org>
	 <4D09BC93.9020502@panasas.com>
	 <1292514922.2912.32.camel@heimdal.trondhjem.org>
	 <4D0A3D44.2000101@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 16 Dec 2010 12:35:16 -0500
Message-ID: <1292520916.2912.45.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-12-16 at 18:24 +0200, Benny Halevy wrote:
> On 2010-12-16 17:55, Trond Myklebust wrote:
> > OK, so why not just go the whole hog and do that for all rare cases,
> > including the one where the server recalls a layout segment that we
> > happen to be doing I/O to?
> > 
> > The case we should be optimising for is the one where the layout is
> > recalled, and no I/O to that segment is in progress. For that case,
> > returning OK, then doing the LAYOUTRETURN instead of just returning
> > NOMATCHING_LAYOUT is clearly wrong: it adds a completely unnecessary
> > round trip to the server. Agreed?
> 
> I agree that if the client can free the recalled layout synchronously
> and if it need not send a LAYOUTCOMMIT or LAYOUTRETURN (e.g. in the objects case)
> it can simply return NFS4ERR_NOMATCHING_LAYOUT.

Objects and blocks != wave 2. We can cross that bridge when we get to
it.

> > 
> > As for the much rarer case of a recall of a layout that is in use, how
> > does LAYOUTRETURN speed things up? As far as I can see, the MDS is still
> > going to return NFS4ERR_DELAY to the client that requested the
> > conflicting LAYOUTGET. That client then has to resend this LAYOUTGET
> > request, at a time when the first client may or may not have returned
> > its layout segment. So how is LAYOUTRETURN going to make all this a fast
> > and scalable process?
> > 
> 
> First, the server does not have to poll the client and waste cpu and network
> resources on that.

...but this is a ____rare____ case. If you are seeing noticeable effects
on the network from this, then something is wrong. If that is ever the
case, then you should be writing through the MDS anyway.

Furthermore, the MDS does need to be able to cope with NFS4ERR_DELAY
anyway, so why add the extra complexity to the client?

> Second, for the competing client, with notifications, it too does not have
> to poll the server and can wait on getting the notification when the
> layout becomes available.

There is no notification of layout availability in RFC5661. Lock
notification is for byte range locks, and device id notification is for
device ids. The rest is for directory notifications.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

