From: Jeff Layton <jlayton@redhat.com>
Subject: Re: NFS/IPv6 servers on GNU/Linux?
Date: Sat, 23 Jan 2010 09:30:34 -0500
Message-ID: <20100123093034.11413b9d@tlielax.poochiereds.net>
References: <1263907662-19107-1-git-send-email-jlayton@redhat.com>
	<87y6jp56cw.fsf@violet.siamics.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Ivan Shmakov <ivan-tPYS1JDixHzCyp4qypjU+w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57214 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751042Ab0AWOao (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 23 Jan 2010 09:30:44 -0500
In-Reply-To: <87y6jp56cw.fsf-Hr8DDCuc/255On46OghOUKxOck334EZe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 23 Jan 2010 18:54:39 +0600
Ivan Shmakov <ivan-tPYS1JDixHzCyp4qypjU+w@public.gmane.org> wrote:

> >>>>> "JL" == Jeff Layton <jlayton...> writes:
> 
>  JL> We're poised to enable IPv6 in nfs-utils in distros. There is a
>  JL> potential problem however. mount.nfs will prefer IPv6 addrs.
> 
>  JL> If someone has a working IPv4 server today that has an IPv6
>  JL> address, then clients may start trying to mount over that
>  JL> address. If the server doesn't support NFS serving over IPv6 (and
>  JL> virtually no linux servers currently do),
> 
> 	Huh?  Are there any GNU/Linux-based servers that do?  What are
> 	the prerequisites?
> 
> 	(Sorry, I wasn't following the topic recently.)
> 
>  JL> then the mount will start failing.
> 
> [...]
> 

The client-side nfs-utils pieces are pretty much complete and working.
Aside from a few that are set up for testing, no Linux NFS servers
support IPv6 yet.

exportfs and mountd in mainline nfs-utils don't yet support IPv6. It's
supported in rpc.nfsd, but hardcoded off for now until mountd and
exportfs catch up.

Chuck Lever has a patch stack for mountd and exportfs in his nfs-utils
tree that basically works, but it's still preliminary and not ready to
be committed yet. More testing of that code would be helpful.

-- 
Jeff Layton <jlayton@redhat.com>
