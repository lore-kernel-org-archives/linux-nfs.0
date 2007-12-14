From: Orion Poplawski <orion@cora.nwra.com>
Subject: Re: Client performance questions
Date: Thu, 13 Dec 2007 17:07:26 -0700
Message-ID: <fjshfu$6f6$1@ger.gmane.org>
References: <0a15723c4b267d4eb8b5ad05800315c0@swip.net> <1197328226.25938.7.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:40720 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934966AbXLNAHi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Dec 2007 19:07:38 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1J2y5U-0005FL-0q
	for linux-nfs@vger.kernel.org; Fri, 14 Dec 2007 00:07:32 +0000
Received: from inferno.cora.nwra.com ([65.44.101.162])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 14 Dec 2007 00:07:32 +0000
Received: from orion by inferno.cora.nwra.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 14 Dec 2007 00:07:32 +0000
In-Reply-To: <1197328226.25938.7.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> 
> Have you tried increasing the value
> in /proc/sys/fs/nfs/nfs_congestion_kb ?

Well, I just came across this message while trying to improve NFS 
performance locally.  On my F8 client, it is set to 30400 by default. 
Changing to 60800 kills performance.  Writes go from ~20MB/s to ~5MB/s, 
reads from ~80MB/s to ~47MB/s as measured by bonnie++.

Expected?


-- 
Orion Poplawski
Technical Manager                     303-415-9701 x222
NWRA/CoRA Division                    FAX: 303-415-9702
3380 Mitchell Lane                  orion@cora.nwra.com
Boulder, CO 80301              http://www.cora.nwra.com

