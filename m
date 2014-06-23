Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:39947 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755718AbaFWQMX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 12:12:23 -0400
Date: Mon, 23 Jun 2014 09:12:22 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 008/104] NFSd: Ensure that nfs4_file_get_access
 enforces share access modes
Message-ID: <20140623161222.GF24193@infradead.org>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
 <1403189450-18729-9-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1403189450-18729-9-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 19, 2014 at 10:49:14AM -0400, Jeff Layton wrote:
> Lock atomicity requires us to check the share access mode when we
> actually open the file. Note that ideally this would also be atomic
> with file creation.
> 
> With the change to make nfs4_file_get_access enforce the share mode, we
> now have a bogus WARN_ON that can fire. It's now normal to call
> nfs4_file_get_access before populating the fi_fds field for the open
> flag, so we should no longer warn on that situation.

Which change is that?  Seems like this is a previous commit, so it
would be good to refer to it explicitly.

> The other case is a WARN_ON that can occur if there's a O_RDWR open
> already present. I'm unclear on why we'd WARN_ON in that case. This
> patch removes it, but please do enlighten me if there's some reason
> we ought to keep it instead.

I have a really hard time mapping from what's in this description
to what happens in the patch.

Looking over the patch I can see that it:

adds a fi_share_deny field to struct nfs4_file, which gets set up in
nfs4_file_get_access, and cleared from nfs4_file_put_access, as well
as some general refactoring around nfs4_file_get_access.  Can you
split the refactor into a first patch that has a description what's
going on, and keep the addition of the deny mask separate, again
including a description of what it's trying to help with?
