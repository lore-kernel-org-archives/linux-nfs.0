Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcdn-iport-6.cisco.com ([173.37.86.77]:36909 "EHLO
	rcdn-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110AbcEYVQK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2016 17:16:10 -0400
Subject: Re: [PATCH RESEND] vfs: pass the flag setting by fcntl() to vfs
To: Al Viro <viro@ZenIV.linux.org.uk>
References: <c6b1075a-2eb5-a065-96ac-fc06ec04ea0f@cisco.com>
 <5e560bce-837d-c1eb-7f6a-eb4fbe994433@cisco.com>
 <20160525195229.GG14480@ZenIV.linux.org.uk>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Miklos Szeredi <miklos@szeredi.hu>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Enke Chen <enkechen@cisco.com>
From: Enke Chen <enkechen@cisco.com>
Message-ID: <a55e8a17-6637-0032-bd2d-32fd893fa90b@cisco.com>
Date: Wed, 25 May 2016 14:16:07 -0700
MIME-Version: 1.0
In-Reply-To: <20160525195229.GG14480@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, Al:

I did reply to the original thread:

-------------------
> And that's not a supported use case.
> 

Understood, and that is the reason for the simple patch :-)

User-space networking stacks exist for several reasons, e.g., for migrating
from micro-kernel based systems, or for avoiding large changes to the networking
stack in the kernel.
------------------

Let me clarify a bit more:

FUSE, being a file system, should be able to support the same flag setting as
in the kernel. The patch facilitates that by passing the flags to the vfs.

Does this help? 

Thanks.   -- Enke

On 5/25/16 12:52 PM, Al Viro wrote:
> On Wed, May 25, 2016 at 12:03:23PM -0700, Enke Chen wrote:
>> Hi, Folks:
>>
>> Could you accept this patch submitted on May 5, 2016?
> 
> Not until you've addressed the objections in the original thread.
> And no, "we have an application that wants it" does not qualify.
> 
> NAKed-by: Al Viro <viro@zeniv.linux.org.uk>
> 
