Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:32986 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754510AbcHSRsO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Aug 2016 13:48:14 -0400
Date: Fri, 19 Aug 2016 13:38:30 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Martin Pitt <martin.pitt@ubuntu.com>
Subject: Re: [PATCH 1/2] systemd: improve ordering between nfs-server and
 various mounts
Message-ID: <20160819173830.GK32329@fieldses.org>
References: <147157095612.26568.14161646901346011334.stgit@noble>
 <147157115637.26568.2867884353016441810.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <147157115637.26568.2867884353016441810.stgit@noble>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 19, 2016 at 11:45:56AM +1000, NeilBrown wrote:
> Commit: 1e41488f428c ("systemd: Order NFS server before client")
> 
> added an ordering dependency between network mounts and nfs-server.
> This is good for loop-back NFS mounts as it ensures the server
> will remain until after the mountpoint is unmounted.
> 
> However is is bad for _net mounts (such as those via iSCSI) which
> are being NFS exported.
> 
> nfs-server needs to be start *after* exported filesystems are mounted,
> and *before* NFS filesystems are mounted.  systemd isn't able to make
> this distinction natively, so we need to help it.
> 
> This patch adds a systemd generator which creates a drop-in for
> nfs-server.services so that it is started "After" any "nfs" or "nfs4"

s/After/Before/ ?

The code's right:

> +	fstab = setmntent("/etc/fstab", "r");
> +	while ((mnt = getmntent(fstab)) != NULL) {
> +		if (strcmp(mnt->mnt_type, "nfs") != 0 &&
> +		    strcmp(mnt->mnt_type, "nfs4") != 0)
> +			continue;
> +		fprintf(f, "Before= ");
> +		systemd_escape(f, mnt->mnt_dir);
> +		fprintf(f, ".mount\n");

--b.
