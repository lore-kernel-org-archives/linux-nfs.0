Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41856 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965127Ab2CSTd4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Mar 2012 15:33:56 -0400
Date: Mon, 19 Mar 2012 15:33:54 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] idmapd: logging of Local-Realms only lists the
 last realm
Message-ID: <20120319193354.GG23670@fieldses.org>
References: <1332160616-4522-1-git-send-email-steved@redhat.com>
 <51B1F466-FB87-4764-850E-3936DA71F637@oracle.com>
 <4F676E95.3090409@RedHat.com>
 <5295E5C7-2AD7-4D52-B3C1-8C24D964DCEF@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5295E5C7-2AD7-4D52-B3C1-8C24D964DCEF@oracle.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 19, 2012 at 01:43:52PM -0400, Chuck Lever wrote:
> My understanding is that SOB is not about responsibility, but about
> the provenance of the work.  It doesn't matter how large or small the
> patch is.

Well, it can matter in some ways.  For purposes of copyright, e.g., this
patch isn't likely to raise any issues.

> I've never seen another project maintainer drop an SOB like this, so
> I'm just asking (and copying the list for other opinions).  No
> objection, just want to make sure we are dotting our open-source "i"s
> and so on.

I have, for small stuff.  Or e.g. when a patch was written by a student
working with me and I saw previous revisions of it, so I'm willing to
vounch for it being their work.

And agreed with Steved on process--make it easy for the new and drive-by
contributors when it doesn't make extra work for the rest of us, and
they'll figure out the rest of the process later if they need to.

--b.
