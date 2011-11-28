Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:60210 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752190Ab1K1SoD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Nov 2011 13:44:03 -0500
Message-ID: <1322505825.10774.5.camel@lade.trondhjem.org>
Subject: Re: [PATCH] nfs: Define nfs4 module alias
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Stefan Bader <stefan.bader@canonical.com>
Cc: linux-nfs@vger.kernel.org, smb@canonical.com
Date: Mon, 28 Nov 2011 13:43:45 -0500
In-Reply-To: <1322503138-3613-1-git-send-email-stefan.bader@canonical.com>
References: <1322503138-3613-1-git-send-email-stefan.bader@canonical.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2011-11-28 at 18:58 +0100, Stefan Bader wrote: 
> The fact that mount.nfs4 does not find the correct modules to load
> (as fs type is nfs4 and that gets probed) seems to be a common
> pitfall for quite a bit of time now.
> It seems like adding an alias for the nfs4 filesystem type would
> be a simple and acceptable (at least ext4 conditionally seems to
> do the same) way to fix this. I placed the code into the one file
> that already had some module stuff in it.
> Does this look like an acceptable change?

We should really be encouraging people to use mount.nfs rather than
mount.nfs4 these days. The former will automatically load the right
module...

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

