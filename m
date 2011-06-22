Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63049 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757427Ab1FVRcr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jun 2011 13:32:47 -0400
Date: Wed, 22 Jun 2011 13:32:38 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org, neilb@suse.de
Subject: Re: [PATCH] nfs: fix host_reliable_addrinfo (try #2)
Message-ID: <20110622133238.019d6157@tlielax.poochiereds.net>
In-Reply-To: <268F789B-6679-4E24-A9F4-7D6E9FB44040@oracle.com>
References: <1308756953-10277-1-git-send-email-jlayton@redhat.com>
	<268F789B-6679-4E24-A9F4-7D6E9FB44040@oracle.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 22 Jun 2011 10:50:11 -0600
Chuck Lever <chuck.lever@oracle.com> wrote:

> Thanks.
> 
> This is a security problem, but I don't want to lose sight of the original cause of this bug, which was my lack of understanding of the function of the old code and the API contract (return only _one_ address).
> 
> For extra credit, we might check if statd has a similar issue when it matches addresses.
> 

I don't think statd is vulnerable, as best I can tell. I don't see any
places where we do a getnameinfo on an address and then go and use that
to get a list of addresses with getaddrinfo.

Please do double check me on this though. I go on vacation next week
and I think my brain might already have left.

-- 
Jeff Layton <jlayton@redhat.com>
