Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:54521 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751455Ab1CJOrG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Mar 2011 09:47:06 -0500
Date: Thu, 10 Mar 2011 15:46:57 +0100 (CET)
From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
To: linux-nfs@vger.kernel.org
cc: Neil Brown <neilb@suse.de>, "J. Bruce Fields" <bfields@fieldses.org>
Subject: NFS link failure in today's next (gss)
Message-ID: <Pine.LNX.4.64.1103101543090.18816@axis700.grange>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

fs/built-in.o: In function `supported_enctypes_show':
nfsctl.c:(.text+0x7beb0): undefined reference to `gss_mech_get_by_name'
nfsctl.c:(.text+0x7bebc): undefined reference to `gss_mech_put'

.config available on request, but this looks like something pretty simple, 
just a missing "select" somewherein fs/nfsd/Kconfig, perhaps, under 
"config NFSD_V3."

Thanks
Guennadi
---
Guennadi Liakhovetski, Ph.D.
Freelance Open-Source Software Developer
http://www.open-technology.de/
