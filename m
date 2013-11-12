Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:19398 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751472Ab3KLLMz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Nov 2013 06:12:55 -0500
Date: Tue, 12 Nov 2013 06:12:01 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org,
        Stanislav Kinsbursky <skinsbursky@parallels.com>, devel@openvz.org,
        ebiederm@xmission.com, oleg@redhat.com, bfields@fieldses.org,
        bharrosh@panasas.com
Subject: Re: call_usermodehelper in containers
Message-ID: <20131112061201.04cf25ab@tlielax.poochiereds.net>
In-Reply-To: <20131112004703.GB15377@kroah.com>
References: <20131111071825.62da01d1@tlielax.poochiereds.net>
	<20131112004703.GB15377@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 11 Nov 2013 16:47:03 -0800
Greg KH <gregkh@linuxfoundation.org> wrote:

> On Mon, Nov 11, 2013 at 07:18:25AM -0500, Jeff Layton wrote:
> > We have a bit of a problem wrt to upcalls that use call_usermodehelper
> > with containers and I'd like to bring this to some sort of resolution...
> > 
> > A particularly problematic case (though there are others) is the
> > nfsdcltrack upcall. It basically uses call_usermodehelper to run a
> > program in userland to track some information on stable storage for
> > nfsd.
> 
> I thought the discussion at the kernel summit about this issue was:
> 	- don't do this.
> 	- don't do it.
> 	- if you really need to do this, fix nfsd
> 

Sorry, I couldn't make the kernel summit so I missed that discussion. I
guess LWN didn't cover it?

In any case, I guess then that we'll either have to come up with some
way to fix nfsd here, or simply ensure that nfsd can never be started
unless root in the container has a full set of a full set of
capabilities.

One sort of Rube Goldberg possibility to fix nfsd is:

- when we start nfsd in a container, fork off an extra kernel thread
  that just sits idle. That thread would need to be a descendant of the
  userland process that started nfsd, so we'd need to create it with
  kernel_thread().

- Have the kernel just start up the UMH program in the init_ns mount
  namespace as it currently does, but also pass the pid of the idle
  kernel thread to the UMH upcall.

- The program will then use /proc/<pid>/root and /proc/<pid>/ns/* to set
  itself up for doing things properly.

Note that with this mechanism we can't actually run a different binary
per container, but that's probably fine for most purposes.

-- 
Jeff Layton <jlayton@redhat.com>
