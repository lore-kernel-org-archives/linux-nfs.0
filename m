Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44205 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751913AbbJHMQM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Oct 2015 08:16:12 -0400
Date: Thu, 8 Oct 2015 08:16:10 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Stanislav Kinsbursky <skinsbursky@virtuozzo.com>,
        kbuild test robot <lkp@intel.com>, kbuild-all@01.org
Subject: Re: [PATCH v2] lockd: get rid of reference-counted NSM RPC clients
Message-ID: <20151008121610.GA32078@fieldses.org>
References: <201510071927.5zx6Lh6E%fengguang.wu@intel.com>
 <1444217995-8233-1-git-send-email-aryabinin@virtuozzo.com>
 <CAHQdGtQNVhqiEx2NytJDkHt+AtYUw6+_JT0q0L0+uZVBaSXT+Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtQNVhqiEx2NytJDkHt+AtYUw6+_JT0q0L0+uZVBaSXT+Q@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 07, 2015 at 05:45:15PM -0400, Trond Myklebust wrote:
> On Wed, Oct 7, 2015 at 7:39 AM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> > Currently we have reference-counted per-net NSM RPC client
> > which created on the first monitor request and destroyed
> > after the last unmonitor request. It's needed because
> > RPC client need to know 'utsname()->nodename', but utsname()
> > might be NULL when nsm_unmonitor() called.
> >
> 
> The other reason for keeping the rpc_client around is to avoid a need
> to do portmapper/rpcbind lookups in a net namespace that may be in the
> process of shutting down. This patchset will reintroduce that
> requirement.

Oops, yes, I think I remember now our dealing with that issue before.

So, that dooms this approach, sorry!

--b.
