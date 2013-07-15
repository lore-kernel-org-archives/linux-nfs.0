Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:59879 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754299Ab3GOLLB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jul 2013 07:11:01 -0400
Date: Mon, 15 Jul 2013 07:11:19 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "bfields@fieldses.org" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: NFS inode cache zap on lock - please advice
Message-ID: <20130715071119.7997d9ce@corrin.poochiereds.net>
In-Reply-To: <51E3A1D7.8090901@parallels.com>
References: <51A6EC86.9010201@parallels.com>
	<20130530114216.GA11854@fieldses.org>
	<51A73FA6.30503@parallels.com>
	<20130712205242.GB10562@fieldses.org>
	<51E3A1D7.8090901@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 15 Jul 2013 11:16:39 +0400
Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:

> 13.07.2013 00:52, bfields@fieldses.org пишет:
> > On Thu, May 30, 2013 at 04:01:42PM +0400, Stanislav Kinsbursky wrote:
> >>
> >> Thanks, Bruce!
> >> I'll have at
> >>
> >> BTW, do you have any decisions what we will do with UMH tracker?
> > Crap, apologies, I completely dropped this.  Have you looked at it
> > again lately?
> 
> Don't worry, it's all right. And I added Jeff and mailing list to 
> recipients.
> 
> I was thinking about using kernel_thread() instead of kthread_create().
> This might work, because will give us kthread with same root and same 
> capabilities as mount caller had.
> 
> What you, guys, think about it?

Well, it's not the caller of mount that we're concerned with here. It's
the caller of rpc.nfsd. That program is going to make the kernel spawn
a bunch of nfsd kthreads and then exit. So I guess the basic idea here
is to preserve the namespace info, root and creds from that process
before it exits. Spawning a kthread would work for that, and might be
simplest, but we should weigh this idea carefully before we settle on
it.

Let's assume for a moment that we want to do all of this in userspace
instead (Eric B.'s first suggestion). I assume the kernel would need to
pass a fd to the program so it can call setns() with it. Where would it
get this fd, considering that we're calling this from a nfsd kthread?

What else would it need? Would it need a path to chroot() to? Credential
info so it can call setuid/setgid?

Other caveats might be that the binary needn't exist in the container
to which you're chrooting. That's not really a problem as long as all
the libs get linked in before the program does the switcharoo, but it
might make troubleshooting problems in this code difficult from a
user sitting in that container.

-- 
Jeff Layton <jlayton@redhat.com>
