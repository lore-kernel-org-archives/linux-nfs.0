Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32387 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753298Ab1I1TJV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Sep 2011 15:09:21 -0400
Date: Wed, 28 Sep 2011 15:09:14 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfsd grace period open owners
Message-ID: <20110928190914.GK19435@pad.fieldses.org>
References: <4E836218.6000805@netapp.com>
 <20110928182304.GJ19435@pad.fieldses.org>
 <4E836AB6.10709@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E836AB6.10709@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Sep 28, 2011 at 02:43:02PM -0400, Bryan Schumaker wrote:
> On 09/28/2011 02:23 PM, J. Bruce Fields wrote:
> > On Wed, Sep 28, 2011 at 02:06:16PM -0400, Bryan Schumaker wrote:
> >> Hi Bruce,
> >>
> >> I'm updating my fault injection patches to work with your recent stateid changes, and I had a question about something I'm seeing on the server.  When I reboot the server it will enter a grace period and reply to any OPEN requests from the client with NFSERR_GRACE.  I used Wireshark to see that NFSERR_GRACE is returned 12 times before the open succeeds, so 13 OPEN requests total.  When I send the command to forget all open owners I find that 13 open owners have been forgotten, but I only expecting to find 1.  Is this what you would expect the server to do?
> > 
> > Huh.  No, that doesn't sound right.  A failed open doesn't confirm the
> > openowner, and I don't think there's any reason to keep around an
> > unconfirmed openowner.
> 
> Makes sense to me.
> 
> > 
> > Out of curiosity, is the client using a different openowner for each
> > open?
> 
> Yeah, looks like the client is using a different one for each attempt.

Makes sense.  Yes, so it's the obvious problem--we create a new
openowner early in the OPEN processing but don't clean it up on failure.

I'm not sure how to fix it.  By the time we fail later on, we've lost
track of whether the openowner is one we created for this open or not.

Well, wait, I suppose in the former case it will still be unconfirmed.
So probably we should just free op_openowner on exit from open if it's
unconfirmed.

--b.
