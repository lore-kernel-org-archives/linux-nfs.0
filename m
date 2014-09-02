Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36524 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753689AbaIBNVr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Sep 2014 09:21:47 -0400
Date: Tue, 2 Sep 2014 09:21:40 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Boaz Harrosh <openosd@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Shakil A Khan <shakilk1729@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Paul McKenney <paulmck@linux.vnet.ibm.com>,
        William Andros Adamson <andros@netapp.com>,
        Jeffrey Layton <jlayton@primarydata.com>,
        "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Next branch: authgss: authgss.c: Fix warnings for
 uninitizlized variable expire
Message-ID: <20140902132140.GA31793@fieldses.org>
References: <1409571154-50408-1-git-send-email-shakilk1729@gmail.com>
 <CAHQdGtQAwp_QuQE-xmjJNkcxbu7g4QtYQv8qrPT_qWpkym1GZg@mail.gmail.com>
 <5405A15F.2060002@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5405A15F.2060002@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 02, 2014 at 01:52:15PM +0300, Boaz Harrosh wrote:
> On 09/01/2014 04:50 PM, Trond Myklebust wrote:
> > On Mon, Sep 1, 2014 at 7:32 AM, Shakil A Khan <shakilk1729@gmail.com> wrote:
> >> Signed-off-by : Shakil A Khan <shakilk1729@gmail.com>
> >> ---
> >>  net/sunrpc/auth_gss/auth_gss.c |    2 +-
> >>  1 files changed, 1 insertions(+), 1 deletions(-)
> >>
> >> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> >> index afb292c..bea0951 100644
> >> --- a/net/sunrpc/auth_gss/auth_gss.c
> >> +++ b/net/sunrpc/auth_gss/auth_gss.c
> >> @@ -1387,7 +1387,7 @@ gss_key_timeout(struct rpc_cred *rc)
> >>         struct gss_cred *gss_cred = container_of(rc, struct gss_cred, gc_base);
> >>         struct gss_cl_ctx *ctx;
> >>         unsigned long now = jiffies;
> >> -       unsigned long expire;
> >> +       unsigned long expire = 0;
> >>
> >>         rcu_read_lock();
> >>         ctx = rcu_dereference(gss_cred->gc_ctx);
> >> --
> >> 1.7.1
> > 
> > That would be a compiler bug, not a kernel bug. The kernel code is
> > perfectly correct as it stands, and will never access the
> > uninitialised variable.
> > 
> 
> Than you will need the infamous uninitialised_var()

You'd rather avoid sprinkling that all over, though.  If nothing else it
increases the chances you'll suppress a legimate warning some day.

And unless I'm missing something this one really does look like an
unambiguous compiler bug.

--b.

> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index afb292c..bea0951 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -1387,7 +1387,7 @@ gss_key_timeout(struct rpc_cred *rc)
>  	struct gss_cred *gss_cred = container_of(rc, struct gss_cred, gc_base);
>  	struct gss_cl_ctx *ctx;
>  	unsigned long now = jiffies;
> -	unsigned long expire;
> +	unsigned long uninitialised_var(expire);
>  
>  	rcu_read_lock();
>  	ctx = rcu_dereference(gss_cred->gc_ctx);
> 
> Cheers
> Boaz
