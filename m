Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34516 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754991Ab2IMR55 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Sep 2012 13:57:57 -0400
Date: Thu, 13 Sep 2012 13:57:54 -0400
To: "Adamson, Andy" <William.Adamson@netapp.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/4] RFC Avoid expired credential keys for buffered writes
Message-ID: <20120913175754.GA6566@fieldses.org>
References: <1346961251-2554-1-git-send-email-andros@netapp.com>
 <20120910145732.4d800f5b@corrin.poochiereds.net>
 <7851A663D3BF5E41B9E166C2C7A42145102B2F5A@SACEXCMBX02-PRD.hq.netapp.com>
 <20120910160858.552bec1b@corrin.poochiereds.net>
 <7851A663D3BF5E41B9E166C2C7A42145102B48E8@SACEXCMBX02-PRD.hq.netapp.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA908F9DD4F@SACEXCMBX04-PRD.hq.netapp.com>
 <7851A663D3BF5E41B9E166C2C7A42145102B4C9F@SACEXCMBX02-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <7851A663D3BF5E41B9E166C2C7A42145102B4C9F@SACEXCMBX02-PRD.hq.netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 12, 2012 at 04:14:38PM +0000, Adamson, Andy wrote:
> 
> On Sep 12, 2012, at 11:21 AM, Myklebust, Trond wrote:
> 
> > On Wed, 2012-09-12 at 15:13 +0000, Adamson, Andy wrote:
> >> After doing more test verification, here are the reasons for the low watermark. Reason #2 is the strongest justification.

1 and 2 don't sound right.  What exactly were the test failures?

The client and server's gss code already check the context expiry for
us--we don't want an extra check in an upper layer on the client.

The context *will* expire unexpectedly sometimes, and we do have to
handle that.  (The server's clock could be a tad faster than the
server's, or the server could reboot, etc., etc.)

I agree with all the suggestions for trying to anticipate expiry in the
normal cases and preparing to minimize the damage, that's fine.  But
once the expiry finally comes we should leave the existing mechanisms to
do their job.

--b.
