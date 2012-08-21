Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtprelay04.ispgateway.de ([80.67.31.27]:36215 "EHLO
	smtprelay04.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751817Ab2HUKXr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Aug 2012 06:23:47 -0400
Message-ID: <503361AF.8030707@cape-horn-eng.com>
Date: Tue, 21 Aug 2012 12:23:43 +0200
From: Richard Ems <richard.ems@cape-horn-eng.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: Fix Oopses in nfs_lookup_revalidate and nfs4_lookup_revalidate
References: <1345063762-32530-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1345063762-32530-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/15/2012 10:49 PM, Trond Myklebust wrote:
> This Oops affects 3.5 kernels and older, and is due to lookup_one_len()
> calling down to the dentry revalidation code with a NULL pointer
> to struct nameidata.
> 
> It is fixed upstream by commit 0b728e1911c (stop passing nameidata *
> to ->d_revalidate())
> 
> Reported-by: Richard Ems <richard.ems@cape-horn-eng.com>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


Hi Trond,

I don't see this patch going into 3.5.3 at 
http://www.kernel.org/pub/linux/kernel/v3.0/stable-review/patch-3.5.3-rc1.gz .
Shouldn't it be included in 3.5.3 ?

Thanks,
Richard


-- 
Richard Ems       mail: Richard.Ems@Cape-Horn-Eng.com

Cape Horn Engineering S.L.
C/ Dr. J.J. Dómine 1, 5º piso
46011 Valencia
Tel : +34 96 3242923 / Fax 924
http://www.cape-horn-eng.com
