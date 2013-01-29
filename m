Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29053 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751386Ab3A2NeI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jan 2013 08:34:08 -0500
Date: Tue, 29 Jan 2013 08:33:41 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 01/16] nfsd: fix IPv6 address handling in the DRC
Message-ID: <20130129083341.486a83ba@tlielax.poochiereds.net>
In-Reply-To: <C741FD4B-4A16-4E43-A0C4-C638A47A6F32@oracle.com>
References: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
	<1359402082-29195-2-git-send-email-jlayton@redhat.com>
	<5AD4F061-69A6-47F5-B20A-34B8DCC2EB5E@oracle.com>
	<20130128150502.4c5f497b@tlielax.poochiereds.net>
	<321A7110-AD03-49EB-A158-246FC8BD24E1@oracle.com>
	<20130128152643.2b136d37@tlielax.poochiereds.net>
	<615875E4-820D-487E-99CF-9ABD46121966@oracle.com>
	<20130128154555.3a93c6dc@tlielax.poochiereds.net>
	<F6E767BA-D9F9-49FE-AABB-75EA20AF827A@oracle.com>
	<20130128160617.3288501c@tlielax.poochiereds.net>
	<C741FD4B-4A16-4E43-A0C4-C638A47A6F32@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 28 Jan 2013 16:32:55 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Jan 28, 2013, at 4:06 PM, Jeff Layton <jlayton@redhat.com> wrote:
> 
> > On Mon, 28 Jan 2013 15:54:26 -0500
> > Chuck Lever <chuck.lever@oracle.com> wrote:
> > 
> >> Since we don't know for sure how this works, we should have someone create unit tests to explore this, fix any bugs that are discovered, and ensure that it continues to work.
> >> 
> > 
> > I'm fairly sure I understand how it works (though I did need to go back
> > and refresh my memory here). I'm not sure how you'd go about writing
> > such a test for this, but let me know if you do and I'll be happy to
> > take a look.
> 
> I guess I'm abusing the term "unit test."  I mean simply that someone has a set up that uses link-local addresses and tries all the typical NFSv4 tests with it, and especially the ones that involve the DRC.
> 

Well, there's the rub isn't it...

In order to test that properly, you need a multi-homed server and
clients on each end that have the *same* link-local address, so that the
sockaddr_in6's only differ by scopeid.

I'm not sure how to set something like that up. Maybe with
virtualization somehow.? Even if you can though, it's not going to be
easy to "bottle" such a test so you can trivially run it at will to
check for regressions.
 
-- 
Jeff Layton <jlayton@redhat.com>
