Return-Path: SteveD@redhat.com
Message-ID: <54C954AA.2010009@RedHat.com>
Date: Wed, 28 Jan 2015 16:29:14 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Benjamin Coddington <bcodding@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/6] mount.nfs default version
References: <cover.1416319371.git.bcodding@redhat.com>
In-Reply-To: <cover.1416319371.git.bcodding@redhat.com>
Content-Type: text/plain; charset=utf-8
List-ID: <linux-nfs.vger.kernel.org>



On 11/18/2014 09:06 AM, Benjamin Coddington wrote:
> Here's the work posted yesterday broken out a bit with an addition of
> enabling nfsmount.conf by default, and the change to autonegotiate starting
> with version 4.2 (instead of 4.0) when no version is specified in either
> config or mount option.
> 
> Benjamin Coddington (6):
>   mount.nfs: default enable mount config file (nfsmount.conf)
>   mount.nfs: fix a comment typo in parse options
>   mount.nfs: parse options - add helper po_contains_prefix
>   mount.nfs: Add struct nfs_version and generalize version parsing
>   nfsmount.conf: Always parse versions
>   mount.nfs: configurable minor version defaults
> 
>  configure.ac             |    8 +-
>  utils/mount/configfile.c |   36 +-----------
>  utils/mount/network.c    |  122 ++++++++++++++++++-------------------
>  utils/mount/network.h    |   15 ++++-
>  utils/mount/nfsumount.c  |    4 +-
>  utils/mount/parse_opt.c  |   26 ++++++++-
>  utils/mount/parse_opt.h  |    2 +
>  utils/mount/stropts.c    |  150 +++++++++++++++++++++++++++++++---------------
>  8 files changed, 209 insertions(+), 154 deletions(-)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Committed... But I did have to fix an issue with the first patch
See commit e1a49cf3... No biggie... 

steved.
