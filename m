Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 8bytes.org ([85.214.48.195]:55990 "EHLO
	h2027444.stratoserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750847Ab2FGPYZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jun 2012 11:24:25 -0400
Received: from localhost (localhost [127.0.0.1])
	by h2027444.stratoserver.net (Postfix) with SMTP id 8712B12AFE9
	for <linux-nfs@vger.kernel.org>; Thu,  7 Jun 2012 17:04:57 +0200 (CEST)
Date: Thu, 7 Jun 2012 17:04:56 +0200
From: Joerg Roedel <joro@8bytes.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: NFS regression in v3.5-rc1: mount.nfs yells about incorrect mount
 option
Message-ID: <20120607150456.GO12795@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

since Linux v3.5-rc1 I experience problems using NFS between my
machines. One of my test-machines gives me:

root@chrom:~# mount lemmy:/data/repos /data/lemmy
mount.nfs: an incorrect mount option was specified

The same works fine on v3.4. I tried to bisect but got different errors
in between. In the end, using every non-working case as bad, bisection
pointed to:

	db83335 NFS: Let mount data parsing set the NFS version

but that at that commit the kernel panics when trying to mount the NFS
tree. Please let me know if you need any additional information.

Regards,

	Joerg


