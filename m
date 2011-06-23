Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57006 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932831Ab1FWUaP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Jun 2011 16:30:15 -0400
Date: Thu, 23 Jun 2011 16:30:12 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <trond@netapp.com>
Subject: Re: autoload rpcsec_gss_krb5
Message-ID: <20110623203012.GD12357@fieldses.org>
References: <20110622213209.GA3010@fieldses.org>
 <20110623155947.GC8911@fieldses.org>
 <BANLkTikS+Y-V=f3Pm8AF-AUoeYVo==4SzA@mail.gmail.com>
 <20110623201117.GB12357@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110623201117.GB12357@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jun 23, 2011 at 04:11:17PM -0400, J. Bruce Fields wrote:
> On Thu, Jun 23, 2011 at 10:06:14PM +0200, Tigran Mkrtchyan wrote:
> > I recall a discussion at connectaton 2010, where Peter Staubach from
> > RedHat ( at that time )
> > requested a way to disable pNFS without rebuilding the kernel.
> > 
> > Probably that's why autoload is not implemented.
> 
> Well, autoload *is* implemented, you just have to add an alias command
> to modprobe.conf before it'll work.
> 
> And if we embed the alias in the module instead, it will still be
> possible to disable autloading by adding a "backlist <modulename>" to
> modproble.conf.
> 
> So I don't *think* that's the issue, unless I've missed something.

So can we just do this?  (Untested.)

--b.

commit 8b3065071b5469c428d70052c80f1df3cb398da6
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Jun 23 16:15:39 2011 -0400

    pnfs: simplify pnfs files module autoloading
    
    Embed the necessary alias into the module rather than waiting for
    someone to add it to /etc/modprobe.conf
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 4269088..eb65f82 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -896,5 +896,7 @@ static void __exit nfs4filelayout_exit(void)
 	pnfs_unregister_layoutdriver(&filelayout_type);
 }
 
+MODULE_ALIAS("nfs-layouttype4-1");
+
 module_init(nfs4filelayout_init);
 module_exit(nfs4filelayout_exit);
