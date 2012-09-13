Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39057 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750828Ab2IMSV7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Sep 2012 14:21:59 -0400
Date: Thu, 13 Sep 2012 14:21:52 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        Jeff Layton <jlayton@redhat.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/4] RFC Avoid expired credential keys for buffered writes
Message-ID: <20120913182152.GB6566@fieldses.org>
References: <1346961251-2554-1-git-send-email-andros@netapp.com>
 <20120910145732.4d800f5b@corrin.poochiereds.net>
 <7851A663D3BF5E41B9E166C2C7A42145102B2F5A@SACEXCMBX02-PRD.hq.netapp.com>
 <20120910160858.552bec1b@corrin.poochiereds.net>
 <7851A663D3BF5E41B9E166C2C7A42145102B48E8@SACEXCMBX02-PRD.hq.netapp.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA908F9DD4F@SACEXCMBX04-PRD.hq.netapp.com>
 <7851A663D3BF5E41B9E166C2C7A42145102B4C9F@SACEXCMBX02-PRD.hq.netapp.com>
 <20120913175754.GA6566@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA908FA4EBD@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA908FA4EBD@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 13, 2012 at 06:09:05PM +0000, Myklebust, Trond wrote:
> On Thu, 2012-09-13 at 13:57 -0400, J. Bruce Fields wrote:
> > On Wed, Sep 12, 2012 at 04:14:38PM +0000, Adamson, Andy wrote:
> > > 
> > > On Sep 12, 2012, at 11:21 AM, Myklebust, Trond wrote:
> > > 
> > > > On Wed, 2012-09-12 at 15:13 +0000, Adamson, Andy wrote:
> > > >> After doing more test verification, here are the reasons for the low watermark. Reason #2 is the strongest justification.
> > 
> > 1 and 2 don't sound right.  What exactly were the test failures?
> > 
> > The client and server's gss code already check the context expiry for
> > us--we don't want an extra check in an upper layer on the client.
> > 
> > The context *will* expire unexpectedly sometimes, and we do have to
> > handle that.  (The server's clock could be a tad faster than the
> > server's, or the server could reboot, etc., etc.)
> > 
> > I agree with all the suggestions for trying to anticipate expiry in the
> > normal cases and preparing to minimize the damage, that's fine.  But
> > once the expiry finally comes we should leave the existing mechanisms to
> > do their job.
> 
> Right, but the problem that the existing mechanisms have is that due to
> asynchronous reads and writes, the application can end up eating
> sizeable chunks of memory. It can also end up grabbing locks without
> being able to free them afterwards.
> 
> SP4_MACH_CRED solves most of these issues, but NFSv4.1 is less pervasive
> than NFSv4 at this point, so it would be nice to have a solution for the
> latter too.

Yep, understood.

--b.
