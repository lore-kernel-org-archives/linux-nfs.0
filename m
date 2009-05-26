From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/6] nfs-utils: add IPv6 support for rpc.nfsd (try #2)
Date: Tue, 26 May 2009 13:08:44 -0400
Message-ID: <20090526130844.28c1383f@tlielax.poochiereds.net>
References: <1243350951-13462-1-git-send-email-jlayton@redhat.com>
	<5889D6C8-2E49-430C-A2DF-F85F57637A63@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:55279 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751015AbZEZRIt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 May 2009 13:08:49 -0400
In-Reply-To: <5889D6C8-2E49-430C-A2DF-F85F57637A63@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 26 May 2009 11:24:57 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> We should also ensure this behaves itself if IPv6 support is built  
> into the kernel, but ipv6.ko is blacklisted.
> 

Good call. I tested that and rpc.nfsd errored out when creating an
IPv6 socket. It should be simple enough to fix. Let me do that and
I'll resend in another day or two.

-- 
Jeff Layton <jlayton@redhat.com>
