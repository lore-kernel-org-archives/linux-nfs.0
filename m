Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38045 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751153Ab0INR2z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Sep 2010 13:28:55 -0400
Date: Tue, 14 Sep 2010 13:27:48 -0400
To: "fanpost@uninverse.de" <fanpost@uninverse.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS strange sync issues - different versions of same file
 using multiple clients
Message-ID: <20100914172748.GB2409@fieldses.org>
References: <E1OvRdx-0008Pj-AQ@saphir-ld-031.synserver.de>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <E1OvRdx-0008Pj-AQ@saphir-ld-031.synserver.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Sep 14, 2010 at 11:17:37AM +0200, fanpost@uninverse.de wrote:
> Hello Group,
> 
> I already send this post to the opensuse forum without response,
> maybe you can help:
> 
> we recognized very strange behaviour of nfs:
> 
> Use case:
> 
> Users access their files on different host through nfs4 (plain sys auth no kerberos sec).
> They modify a c++ program and change parameters,
> recompile it and execute it on different hosts for simulation.
> 
> We now observed that sometimes even after modifying and recompiling
> the binary, an o l d version of the same binary is executed
> The Binary resides on a nfs share.
> 
> 1) Write changes X to the Program and compile + execute it on PC A
> 2) Write changes Y to the Program and compile + execute it on PC B
> 
> Instead of executing Program Y on PC B results and logging shows that actually the old version
> (X) is executed on PC B.
> 
> Neither the problem nor the working execution is 100% reproducible.
> Seems to have something to do with caching.

If you downgrade to nfs3, or if you run

	echo 0 >/proc/sys/fs/leases-enable

before starting the nfs server, does the problem go away?

--b.
