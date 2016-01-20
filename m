Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48137 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755285AbcATWea (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jan 2016 17:34:30 -0500
Date: Wed, 20 Jan 2016 17:34:29 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andrew Elble <aweits@rit.edu>
Cc: linux-nfs@vger.kernel.org, dros@primarydata.com
Subject: Re: [PATCH v2 0/3] Deal with lost delegations and EKEYEXPIRED
Message-ID: <20160120223429.GA26860@fieldses.org>
References: <1453147702-42961-1-git-send-email-aweits@rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1453147702-42961-1-git-send-email-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 18, 2016 at 03:08:19PM -0500, Andrew Elble wrote:
> I've finally discovered that the majority of our lost delegation problems
> come from EKEYEXPIRED.

These patches only seem to change behavior in WRONGSEC cases.  Could you
explain what these patches have to do with the lost delegation and
EKEYEXPIRED problems?

--b.

> This seems to work fine in our environment, but
> I am unsure of the ramifications of this in a broader context, so it's
> time to get other folks to look at it.
> 
> v2: fix kbuild robot err on CONFIG_NFSD_V4 unset
>     kerneldoc header on nfsd4_spo_must_allow
>     removed LAYOUTRETURN as I currently can't test it
> 
> Andrew Elble (3):
>   nfs/nfsd: Move useful bitfield ops to a commonly accessible place
>   nfsd: allow mach_creds_match to be used more broadly
>   nfsd: implement machine credential support for some operations
> 
>  fs/nfsd/export.c        |  4 +++
>  fs/nfsd/nfs4proc.c      | 69 +++++++++++++++++++++++++++++++++++++++++++++++++
>  fs/nfsd/nfs4state.c     | 32 ++++++++++++++++++-----
>  fs/nfsd/nfs4xdr.c       | 51 +++++++++++++++++-------------------
>  fs/nfsd/nfsd.h          |  5 ++++
>  fs/nfsd/state.h         |  1 +
>  fs/nfsd/xdr4.h          |  5 ++++
>  include/linux/nfs4.h    | 11 ++++++++
>  include/linux/nfs_xdr.h | 11 --------
>  9 files changed, 143 insertions(+), 46 deletions(-)
> 
> -- 
> 2.6.3
