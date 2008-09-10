From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] sunrpc: fix oops in rpc_create() when the mount namespace is unshared
Date: Wed, 10 Sep 2008 13:02:10 -0700
Message-ID: <m1ej3rixbx.fsf@frodo.ebiederm.org>
References: <48C52B29.4020204@fr.ibm.com> <20080909124311.GA10053@us.ibm.com>
	<m18wu1nyon.fsf@frodo.ebiederm.org>
	<20080909152952.GA21207@us.ibm.com>
	<DE845309-1684-472A-8269-78AB3A2823A9@oracle.com>
	<m1fxo9mba5.fsf@frodo.ebiederm.org> <48C791F9.8090606@fr.ibm.com>
	<76bd70e30809100812r4a7fa71crfc7196350e3ed1cf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Cedric Le Goater" <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	"Linux Containers" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:33282 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901AbYIJUFA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Sep 2008 16:05:00 -0400
In-Reply-To: <76bd70e30809100812r4a7fa71crfc7196350e3ed1cf-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Chuck Lever's message of "Wed, 10 Sep 2008 11:12:04 -0400")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"Chuck Lever" <chuck.lever@oracle.com> writes:

> That makes sense.
>
> This is likely coming from lockd_down(), and is almost certainly not
> coming from the same uts namespace as the lockd_up() that did the
> pmap_set, which was done by the first NFS mount done in the first uts
> namespace on the system.  It's just something that the kernel has to
> do for maintenance.
>
> There is only one lockd() instance that is shared among all the uts
> namespaces, right?  In this case, what is the correct utsname to use?

Interesting.

As a general rule I would say we should capture the uts instance
in locked_up().  And use the same instance in locked_down().

I'm not at all familiar with how locked interacts with nfs mounts
in a practical sense.  Is there one locked instance (or at least context)
per nfs mount?

The way I would expect things to work is that when we mount an nfs filesystem
from an nfs server.  We would create a locked context for that server, that
additional nfs mounts to the same nfs server could share.

The way I would expect nfs to interact with the namespaces is for the nfs
mount to capture the uts and network namespaces, and use them for all
transactions relating to the mount.  In particular when creating
or a locked context the nfs mount would use the uts namespace and the
network namespace as discriminators to see if an existing locked context
is the same.

I don't think nfs has a 1-1 thread to context model which is where things
get really hazy for me.


The conservative play is to always force use of the initial namespace
and to deny creation of mounts that would use different namespaces.  In part
because the initial version of the namespace always exists.  Which means
as relates to Cedrics initial patch we would still need to know which
mounts should cause us to use a different uts namespace so we can deny
them.

Eric
