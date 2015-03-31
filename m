Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:36013 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754723AbbCaPLx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Mar 2015 11:11:53 -0400
Received: by qcgx3 with SMTP id x3so16083054qcg.3
        for <linux-nfs@vger.kernel.org>; Tue, 31 Mar 2015 08:11:52 -0700 (PDT)
Date: Tue, 31 Mar 2015 11:11:46 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, trond.myklebust@primarydata.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] sunrpc: make debugfs file creation failure non-fatal
Message-ID: <20150331111146.5b71b395@synchrony.poochiereds.net>
In-Reply-To: <20150331142641.GA9961@kroah.com>
References: <1427752698-32431-1-git-send-email-jeff.layton@primarydata.com>
	<20150330234753.GG6901@fieldses.org>
	<20150331140916.GJ6901@fieldses.org>
	<20150331142641.GA9961@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 31 Mar 2015 16:26:41 +0200
Greg KH <gregkh@linuxfoundation.org> wrote:

> On Tue, Mar 31, 2015 at 10:09:16AM -0400, J. Bruce Fields wrote:
> > On Mon, Mar 30, 2015 at 07:47:53PM -0400, J. Bruce Fields wrote:
> > > ACK.--b.
> > 
> > But note the result after this is that the debugfs directories will
> > always miss gss-proxy clients on selinux-enforcing systems.  That could
> > be really confusing.
> 
> So, you shouldn't be relying on debugfs :)
> 

These files are nice to have things for debugging, so debugfs seemed
like the appropriate place for them.

> > So we should still fix debugfs's permission checking.  It doesn't make
> > sense to me as is.
> 
> I don't really understand what the problem is here.  Is selinux
> preventing some debugfs files to be created?  If so, great, it's allowed
> to do that, go fix up your selinux config files to not do that.
> Otherwise, to go around selinux/LSM seems like a bad idea for debugfs to
> be doing, don't you think?
>

gssproxy is SELinux contained and the current policy forbids it from
creating the debugfs files. gssproxy isn't actually creating them
directly however -- the kernel is creating them as a side effect of the
rpc_clnt/rpc_xprt creation.

The question is whether enforcing SELinux policy on debugfs files makes
any sense at all. AFAICT, userland can't really create files directly
on debugfs, can it? So why should we prevent the kernel from doing so
just because it happens to be occurring in the context of a contained
SELinux process?

We certainly can update the selinux policy to allow gssproxy to do
this, but:

a) it's a pain

...and..

b) it seems like we're working around nonsensical debugfs behavior


-- 
Jeff Layton <jlayton@poochiereds.net>
