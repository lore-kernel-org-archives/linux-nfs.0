Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41976 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752721AbcLTSo4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Dec 2016 13:44:56 -0500
Subject: Re: [nfs-utils PATCH 0/10] More support for /etc/nfs.conf
To: NeilBrown <neilb@suse.com>, "J. Bruce Fields" <bfields@redhat.com>
References: <148117122602.31271.13586847542442809540.stgit@noble>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <086b4ae4-91e1-d348-0eb1-2dbc1814a222@RedHat.com>
Date: Tue, 20 Dec 2016 13:44:55 -0500
MIME-Version: 1.0
In-Reply-To: <148117122602.31271.13586847542442809540.stgit@noble>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/07/2016 11:27 PM, NeilBrown wrote:
> Added some missing support for rpc.nfsd, rpc.gss, rpc.svcgssd.
> Fixed a bug.
> 
> Added generic support for "debug="
> This only applies to tools which use the xlog() infrastructure.
> blkmapd used syslog directly and gssd has it's own shim.  I think
> they should be converted to xlog rather than having separate debug=
> support.
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
All 10 committed.... 

Note: with these recent changes the API on how
to configure the NFS daemons and tools have changed
drastically. 

Technology wise it is a step forward... Distro wise
its a pain in the butt ;-) because bridges have to
be built to maintain backwards compatibility.

With that said, very shortly, I will be posting 
a new nfs-utils version (probably nfs-utils-2.1.1).
So if you want something in that not in please
let me know asap.. 

steved.

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
