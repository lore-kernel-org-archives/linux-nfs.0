Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:55944 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738AbcEYTwl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2016 15:52:41 -0400
Date: Wed, 25 May 2016 20:52:29 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Enke Chen <enkechen@cisco.com>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Miklos Szeredi <miklos@szeredi.hu>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH RESEND] vfs: pass the flag setting by fcntl() to vfs
Message-ID: <20160525195229.GG14480@ZenIV.linux.org.uk>
References: <c6b1075a-2eb5-a065-96ac-fc06ec04ea0f@cisco.com>
 <5e560bce-837d-c1eb-7f6a-eb4fbe994433@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5e560bce-837d-c1eb-7f6a-eb4fbe994433@cisco.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 25, 2016 at 12:03:23PM -0700, Enke Chen wrote:
> Hi, Folks:
> 
> Could you accept this patch submitted on May 5, 2016?

Not until you've addressed the objections in the original thread.
And no, "we have an application that wants it" does not qualify.

NAKed-by: Al Viro <viro@zeniv.linux.org.uk>
