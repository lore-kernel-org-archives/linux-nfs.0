Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcdn-iport-3.cisco.com ([173.37.86.74]:23777 "EHLO
	rcdn-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866AbcEIBAJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 May 2016 21:00:09 -0400
Subject: Re: [PATCH] VFS: pass the flag setting by fcntl() to vfs
To: Christoph Hellwig <hch@infradead.org>
References: <ebf888a1-ee45-a79b-6f72-43a8744e0196@cisco.com>
 <c6b1075a-2eb5-a065-96ac-fc06ec04ea0f@cisco.com>
 <20160508104038.GA13657@infradead.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Enke Chen <enkechen@cisco.com>
From: Enke Chen <enkechen@cisco.com>
Message-ID: <c5368586-ba17-11ae-6d48-ee244bedf6f9@cisco.com>
Date: Sun, 8 May 2016 17:50:32 -0700
MIME-Version: 1.0
In-Reply-To: <20160508104038.GA13657@infradead.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As explained in the email, currently the validation of the flags does reach
the vfs, but the setting does not. We have an application that uses the FUSE
to implement a user-space socket, and the flags are needed.

Best regards,

-- Enke

On 5/8/16 3:40 AM, Christoph Hellwig wrote:
> File systems don't really have a business getting this call, and fuse
> file systems even less so.
> 
