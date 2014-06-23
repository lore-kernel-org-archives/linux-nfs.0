Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f175.google.com ([209.85.216.175]:38244 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754880AbaFWQkH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 12:40:07 -0400
Received: by mail-qc0-f175.google.com with SMTP id i8so6176255qcq.6
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jun 2014 09:40:06 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 23 Jun 2014 12:40:05 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 008/104] NFSd: Ensure that nfs4_file_get_access
 enforces share access modes
Message-ID: <20140623124005.59fef4f6@tlielax.poochiereds.net>
In-Reply-To: <20140623161222.GF24193@infradead.org>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
	<1403189450-18729-9-git-send-email-jlayton@primarydata.com>
	<20140623161222.GF24193@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 23 Jun 2014 09:12:22 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Jun 19, 2014 at 10:49:14AM -0400, Jeff Layton wrote:
> > Lock atomicity requires us to check the share access mode when we
> > actually open the file. Note that ideally this would also be atomic
> > with file creation.
> > 
> > With the change to make nfs4_file_get_access enforce the share mode, we
> > now have a bogus WARN_ON that can fire. It's now normal to call
> > nfs4_file_get_access before populating the fi_fds field for the open
> > flag, so we should no longer warn on that situation.
> 
> Which change is that?  Seems like this is a previous commit, so it
> would be good to refer to it explicitly.
> 

Sorry it wasn't clear. The change is in this patch. This is just an
explanation of why the WARN_ON needed to be removed.

> > The other case is a WARN_ON that can occur if there's a O_RDWR open
> > already present. I'm unclear on why we'd WARN_ON in that case. This
> > patch removes it, but please do enlighten me if there's some reason
> > we ought to keep it instead.
> 
> I have a really hard time mapping from what's in this description
> to what happens in the patch.
> 
> Looking over the patch I can see that it:
> 
> adds a fi_share_deny field to struct nfs4_file, which gets set up in
> nfs4_file_get_access, and cleared from nfs4_file_put_access, as well
> as some general refactoring around nfs4_file_get_access.  Can you
> split the refactor into a first patch that has a description what's
> going on, and keep the addition of the deny mask separate, again
> including a description of what it's trying to help with?

Ok, I'll see if I can break that up.

-- 
Jeff Layton <jlayton@primarydata.com>
