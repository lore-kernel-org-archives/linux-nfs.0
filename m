From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC][PATCH] sunrpc: fix oops in rpc_create() when the mount
	namespace is unshared
Date: Tue, 9 Sep 2008 10:29:52 -0500
Message-ID: <20080909152952.GA21207@us.ibm.com>
References: <48C52B29.4020204@fr.ibm.com> <20080909124311.GA10053@us.ibm.com> <m18wu1nyon.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Chuck Lever <chuck.lever@oracle.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:49261 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753885AbYIIPai (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Sep 2008 11:30:38 -0400
In-Reply-To: <m18wu1nyon.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Quoting Eric W. Biederman (ebiederm@xmission.com):
> "Serge E. Hallyn" <serue@us.ibm.com> writes:
> 
> > Thanks, Cedric.  Eric is probably right about the long-term fix, but
> > yeah it might take a while to properly wade through the sunrpc and nfs
> > layers to store the nodename at nfs mount time, and in the meantime this
> > fixes a real oops.
> 
> A very esoteric oops that hasn't shown up for two years.

But an easily reproducible one.

It's not as though we'll stop looking for the right fix just bc we have
this "bad" fix in for a short while.

> Please let's look at this and see what it would take to fix this
> properly.

Of course.  Cedric is looking at the best way to fix it...

> What are we trying to achieve by reading utsname?

It looks like it gets copied into the sunrpc messages so I assume it is
a part of the sunrpc spec?

I don't want to do this, but we *could* put a conditional in utsname()
to have it return init_utsname if current->nsproxy is null...

-serge
