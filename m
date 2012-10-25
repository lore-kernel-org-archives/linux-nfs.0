Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:32874 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932571Ab2JYPtv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Oct 2012 11:49:51 -0400
Date: Thu, 25 Oct 2012 11:49:47 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 1/4] nfsd: add a usermodehelper upcall for NFSv4
 client ID tracking
Message-ID: <20121025154947.GD6846@fieldses.org>
References: <1351089018-24551-1-git-send-email-jlayton@redhat.com>
 <1351089018-24551-2-git-send-email-jlayton@redhat.com>
 <20121024210310.GG6697@fieldses.org>
 <20121025073936.4a57cf24@tlielax.poochiereds.net>
 <20121025150608.GB6846@fieldses.org>
 <20121025112706.086ab02a@corrin.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121025112706.086ab02a@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 25, 2012 at 11:27:06AM -0400, Jeff Layton wrote:
> What disadvantages do you see in doing it the way I've proposed?

Just a vague feeling, along the lines of: APIs can outlast
implementations, and it'll take longer to rip this out if it has to be
removed from both sides....

But it's just an environment variable, easy to ignore, I agree.  I can
live with it.

--b.
