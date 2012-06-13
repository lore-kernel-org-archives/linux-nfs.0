Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41401 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753152Ab2FMLPi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Jun 2012 07:15:38 -0400
Date: Wed, 13 Jun 2012 07:15:35 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH] NFS: hard-code init_net for NFS callback transports
Message-ID: <20120613111535.GA32085@fieldses.org>
References: <20120601095424.24427.74720.stgit@localhost.localdomain>
 <20120611123718.GF7654@fieldses.org>
 <20120612155358.GB22028@fieldses.org>
 <4FD84C47.8080505@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4FD84C47.8080505@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 13, 2012 at 12:16:07PM +0400, Stanislav Kinsbursky wrote:
> 12.06.2012 19:53, J. Bruce Fields написал:
> >On Mon, Jun 11, 2012 at 08:37:18AM -0400, J. Bruce Fields wrote:
> >>On Fri, Jun 01, 2012 at 01:55:47PM +0400, Stanislav Kinsbursky wrote:
> >>>This patch set is a bug fix for Bruce's 3.5 branch.
> >>>I'll rebase this for 3.4 and resend.
> >>
> >>Apologies for neglecting this, I'm done with the bakeathon and should be
> >>back to this soon.
> >>
> >>But, I'm a bit confused: you say you'll rebase this, but I've only seen
> >>two rebased patches for 3.4, and neither looks like a simple rebase of
> >>this one.
> >
> >Oh, I see; the backport of "SUNRPC: new svc_bind() routine introduced"
> >is a combination of the patch by the same name upstream with this one.
> >
> >In future for backports I'd rather keep a one-to-one correspondance
> >between the original patches and the backported patches.  (Even if that
> >means 4.2 might not be as "bisectable".)
> >
> >Also, get this patch into stable by just adding a "cc:
> >stable@vger.kernel.org" with the signed-off at the end of this patch.
> >
> >I've gone ahead and fixed that up; results in the "for-3.4" and
> >"for-3.5" branches of
> >
> >	git://linux-nfs.org/~bfields/linux-topics.git
> >
> >Let me know if anything looks wrong.
> >
> 
> 
> Hi, Bruce. Thanks for you time and guidance with this patch set.
> But I'm a bit confused - what I have to do now? Take the patches
> from your 3.4 branch and send them to "stable"?

No, I'll take care of them.--b.

--b.
