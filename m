Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37088 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755859AbcLNOdy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Dec 2016 09:33:54 -0500
Date: Wed, 14 Dec 2016 09:33:53 -0500
To: NeilBrown <neilb@suse.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH 0/10] More support for /etc/nfs.conf
Message-ID: <20161214143353.GC30113@fieldses.org>
References: <148117122602.31271.13586847542442809540.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <148117122602.31271.13586847542442809540.stgit@noble>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 08, 2016 at 03:27:24PM +1100, NeilBrown wrote:
> Added some missing support for rpc.nfsd, rpc.gss, rpc.svcgssd.
> Fixed a bug.
> 
> Added generic support for "debug="
> This only applies to tools which use the xlog() infrastructure.
> blkmapd used syslog directly and gssd has it's own shim.  I think
> they should be converted to xlog rather than having separate debug=
> support.

Makes sense to me.--b.

> 
> NeilBrown
> 
> ---
> 
> NeilBrown (10):
>       nfsd: move and improve test on valid port
>       nfsd: remove pointless memory allocations.
>       nfsd: add /etc/nfs.conf support for nfsd.port option.
>       nfsd: add /etc/nfs.conf support for host=
>       conffile: allow embedded spaces in values.
>       conffile: fix striping of quotes from values.
>       xlog: Add common support for "debug=??" in /etc/nfs.conf
>       exportfs: allow debugging to be enabled in nfs.conf
>       gssd: add /etc/nfs.conf support
>       svcgssd: add /etc/nfs.conf support
> 
> 
>  support/include/xlog.h          |    1 +
>  support/nfs/conffile.c          |   24 ++++++++++-------
>  support/nfs/xlog.c              |   14 ++++++++++
>  systemd/nfs.conf.man            |   49 ++++++++++++++++++++++++++++++++++-
>  utils/exportfs/exportfs.c       |    5 ++++
>  utils/exportfs/exportfs.man     |    8 ++++++
>  utils/gssd/gssd.c               |   29 +++++++++++++++++++++
>  utils/gssd/gssd.man             |   54 +++++++++++++++++++++++++++++++++++++++
>  utils/gssd/svcgssd.c            |   14 ++++++++++
>  utils/gssd/svcgssd.man          |   17 ++++++++++++
>  utils/mountd/mountd.c           |    1 +
>  utils/nfsd/nfsd.c               |   48 +++++++++++++++++++++++------------
>  utils/nfsd/nfsd.man             |   10 +++++++
>  utils/nfsdcltrack/nfsdcltrack.c |    1 +
>  utils/statd/sm-notify.c         |    1 +
>  utils/statd/statd.c             |    1 +
>  16 files changed, 249 insertions(+), 28 deletions(-)
> 
> --
> Signature
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
