Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36054 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751546Ab2K1QIv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Nov 2012 11:08:51 -0500
Date: Wed, 28 Nov 2012 11:08:47 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Subject: Re: [PATCH 1/2] nfsd: make NFSv4 lease time per net
Message-ID: <20121128160847.GJ11651@fieldses.org>
References: <20121127111007.10271.54338.stgit@localhost.localdomain>
 <20121127111144.10271.97169.stgit@localhost.localdomain>
 <20121128150941.GF11651@fieldses.org>
 <50B629C3.4050903@parallels.com>
 <20121128151542.GI11651@fieldses.org>
 <50B62F38.4010205@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <50B62F38.4010205@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 28, 2012 at 07:35:20PM +0400, Stanislav Kinsbursky wrote:
> 28.11.2012 19:15, J. Bruce Fields пишет:
> >On Wed, Nov 28, 2012 at 07:12:03PM +0400, Stanislav Kinsbursky wrote:
> >>28.11.2012 19:09, J. Bruce Fields пишет:
> >>>On Tue, Nov 27, 2012 at 02:11:44PM +0300, Stanislav Kinsbursky wrote:
> >>>>diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> >>>>index dab350d..4930981 100644
> >>>>--- a/fs/nfsd/nfsctl.c
> >>>>+++ b/fs/nfsd/nfsctl.c
> >>>>@@ -912,7 +912,8 @@ static ssize_t nfsd4_write_time(struct file *file, char *buf, size_t size, time_
> >>>>   */
> >>>>  static ssize_t write_leasetime(struct file *file, char *buf, size_t size)
> >>>>  {
> >>>>-	return nfsd4_write_time(file, buf, size, &nfsd4_lease);
> >>>>+	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
> >>>>+	return nfsd4_write_time(file, buf, size, &nn->nfsd4_lease);
> >>>
> >>>This is called in the context of whatever process writes to
> >>>nfsv4leasetime, so should be using its network namespace, right?
> >>>
> >>
> >>This is, actually, a interim solution to preserve existent logic.
> >>I.e. I'm going to convert "nfsd" filesystem into per-net one (like rpc_pipefs). I, actually, already done it in my tree.
> >>Thus proper network namespace will be taken from nfsd superblock.
> >
> >OK, remind me how that works?  It's mounted just once, but each network
> >namespace gets a different view of the filesystem?
> >
> 
> Nope. It's a single mount point, but per-namespace (network, in our case) - not globally.
> Pointer to namespace will be placed on sb->s_fs_info.

OK, anyway, applying these.

--b.
