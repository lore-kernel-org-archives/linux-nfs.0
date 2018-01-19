Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail02.prevas.se ([62.95.78.10]:43723 "EHLO mail02.prevas.se"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756461AbeASWAO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Jan 2018 17:00:14 -0500
Subject: Re: [PATCH] NFSD: hide unused svcxdr_dupstr()
To: Arnd Bergmann <arnd@arndb.de>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Kinglong Mee <kinglongmee@gmail.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
References: <20180119145410.1096453-1-arnd@arndb.de>
From: Rasmus Villemoes <rasmus.villemoes@prevas.dk>
Message-ID: <428ce7f4-8e01-48ae-a406-262966c63180@prevas.dk>
Date: Fri, 19 Jan 2018 22:58:27 +0100
MIME-Version: 1.0
In-Reply-To: <20180119145410.1096453-1-arnd@arndb.de>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2018-01-19 15:54, Arnd Bergmann wrote:
> There is now only one caller left for svcxdr_dupstr() and this is inside
> of an #ifdef, so we can get a warning when the option is disabled:
> 
> fs/nfsd/nfs4xdr.c:241:1: error: 'svcxdr_dupstr' defined but not used [-Werror=unused-function]
> 
> This adds another #ifdef around the definition.

Why not instead do

-#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
-       if (bmval[2] & FATTR4_WORD2_SECURITY_LABEL) {
+       if (IS_ENABLED(CONFIG_NFSD_V4_SECURITY_LABEL) && bmval[2] &
FATTR4_WORD2_SECURITY_LABEL)

(sorry for whitespace damage, not a real patch).

Rasmus
