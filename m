From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 3/3] nfs-utils: add initial tests for statd that run via
 "make check"
Date: Tue, 5 Jan 2010 16:29:31 -0500
Message-ID: <20100105162931.160c6f23@tlielax.poochiereds.net>
References: <1262706035-4929-1-git-send-email-jlayton@redhat.com>
	<1262706035-4929-4-git-send-email-jlayton@redhat.com>
	<4B436AD3.2080107@RedHat.com>
	<20100105132519.02c3c76d@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Steve Dickson <SteveD@redhat.com>, chuck.lever@oracle.com,
	linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12159 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754505Ab0AEV3g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Jan 2010 16:29:36 -0500
In-Reply-To: <20100105132519.02c3c76d-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 5 Jan 2010 13:25:19 -0500
Jeff Layton <jlayton@redhat.com> wrote:

> On Tue, 05 Jan 2010 11:37:39 -0500
> Steve Dickson <SteveD@redhat.com> wrote:
> 
> > > +export PATH=$PATH:$srcdir/nsm_client
> > How or Where is '$srcdir' set??
> > 
> 
> In the Makefile. Automake sets that along with other variables like
> $top_srcdir. make then stuffs those variables into the environment when
> it forks.
> 

Sorry, I need to correct myself here. Not everything is exported
($top_srcdir isn't in particular). $srcdir is explicitly exported
though. From the automake generated Makefile:

check-TESTS: $(TESTS)
        @failed=0; all=0; xfail=0; xpass=0; skip=0; \
        srcdir=$(srcdir); export srcdir; \

Still, I'll plan to make the scripts set srcdir if it isn't set (and
maybe also check its validity). That should allow us to run these
scripts standalone too.

-- 
Jeff Layton <jlayton@redhat.com>
