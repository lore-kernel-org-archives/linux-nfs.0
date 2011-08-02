Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57668 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753134Ab1HBBJs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Aug 2011 21:09:48 -0400
Date: Mon, 1 Aug 2011 21:09:46 -0400
To: Robert Marcano <robert@marcanoonline.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 / POSIX ACL mapping bug?
Message-ID: <20110802010945.GB16305@fieldses.org>
References: <4E2ED2A0.4030401@marcanoonline.com>
 <20110727154736.GB974@fieldses.org>
 <4E303A09.10906@marcanoonline.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E303A09.10906@marcanoonline.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jul 27, 2011 at 11:47:13AM -0430, Robert Marcano wrote:
> On 07/27/2011 11:17 AM, J. Bruce Fields wrote:
> >On Tue, Jul 26, 2011 at 10:13:44AM -0430, Robert Marcano wrote:
> ...
> >>Is this normal or a bug?, My interpretation is that even that the
> >>mapping of the ACLs is not 100% perfect this simple example should
> >>not be a problem. Is it impossible using NFS to create a shared
> >>directory for a group of users?
> >
> >Without looking at your example carefully, it sounds like the same
> >problem as discussed here:
> >
> >	http://marc.info/?t=123739823200003&r=1&w=2
> 
> Thanks, exactly the same problem, current user umask getting in the
> way of ACL inheritance, looks like the answers is that this is
> currently not possible because the umask is applied client side and
> the NFSv4 protocol does not help to send that info to the server. No
> workaround available (mount option or something like that)

I seem to recall there was a solution proposed in the above thread that
Trond was OK with; if someone wants to read through it and implement
that, I'm sure patches would be welcome....

--b.
