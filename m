Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:35465 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754350AbbJGVpQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2015 17:45:16 -0400
Received: by obbzf10 with SMTP id zf10so24070896obb.2
        for <linux-nfs@vger.kernel.org>; Wed, 07 Oct 2015 14:45:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1444217995-8233-1-git-send-email-aryabinin@virtuozzo.com>
References: <201510071927.5zx6Lh6E%fengguang.wu@intel.com>
	<1444217995-8233-1-git-send-email-aryabinin@virtuozzo.com>
Date: Wed, 7 Oct 2015 17:45:15 -0400
Message-ID: <CAHQdGtQNVhqiEx2NytJDkHt+AtYUw6+_JT0q0L0+uZVBaSXT+Q@mail.gmail.com>
Subject: Re: [PATCH v2] lockd: get rid of reference-counted NSM RPC clients
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Stanislav Kinsbursky <skinsbursky@virtuozzo.com>,
        kbuild test robot <lkp@intel.com>, kbuild-all@01.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 7, 2015 at 7:39 AM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> Currently we have reference-counted per-net NSM RPC client
> which created on the first monitor request and destroyed
> after the last unmonitor request. It's needed because
> RPC client need to know 'utsname()->nodename', but utsname()
> might be NULL when nsm_unmonitor() called.
>

The other reason for keeping the rpc_client around is to avoid a need
to do portmapper/rpcbind lookups in a net namespace that may be in the
process of shutting down. This patchset will reintroduce that
requirement.

Cheers
  Trond
