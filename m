Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcdn-iport-8.cisco.com ([173.37.86.79]:3341 "EHLO
	rcdn-iport-8.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941AbcEISju (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2016 14:39:50 -0400
Subject: Re: [PATCH] VFS: pass the flag setting by fcntl() to vfs
To: Christoph Hellwig <hch@infradead.org>
References: <ebf888a1-ee45-a79b-6f72-43a8744e0196@cisco.com>
 <c6b1075a-2eb5-a065-96ac-fc06ec04ea0f@cisco.com>
 <20160508104038.GA13657@infradead.org>
 <c5368586-ba17-11ae-6d48-ee244bedf6f9@cisco.com>
 <20160509070248.GA24065@infradead.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Enke Chen <enkechen@cisco.com>
From: Enke Chen <enkechen@cisco.com>
Message-ID: <e09b27b0-7f2e-b9c0-e45d-7100b7a952de@cisco.com>
Date: Mon, 9 May 2016 11:39:48 -0700
MIME-Version: 1.0
In-Reply-To: <20160509070248.GA24065@infradead.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, Christoph:

On 5/9/16 12:02 AM, Christoph Hellwig wrote:
> On Sun, May 08, 2016 at 05:50:32PM -0700, Enke Chen wrote:
>> As explained in the email, currently the validation of the flags does reach
>> the vfs, but the setting does not.
> 
> s/vfs/fs/, and yes, that's intentional.
> 
>> We have an application that uses the FUSE
>> to implement a user-space socket, and the flags are needed.
> 
> And that's not a supported use case.
> 

Understood, and that is the reason for the simple patch :-)

User-space networking stacks exist for several reasons, e.g., for migrating
from micro-kernel based systems, or for avoiding large changes to the networking
stack in the kernel.

What is the concern with the patch?

Regards,

-- Enke



