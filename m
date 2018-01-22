Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58478 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751028AbeAVR0U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 Jan 2018 12:26:20 -0500
Date: Mon, 22 Jan 2018 12:26:20 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Rasmus Villemoes <rasmus.villemoes@prevas.dk>
Cc: Arnd Bergmann <arnd@arndb.de>, Jeff Layton <jlayton@kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Kinglong Mee <kinglongmee@gmail.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] NFSD: hide unused svcxdr_dupstr()
Message-ID: <20180122172620.GA15913@fieldses.org>
References: <20180119145410.1096453-1-arnd@arndb.de>
 <428ce7f4-8e01-48ae-a406-262966c63180@prevas.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <428ce7f4-8e01-48ae-a406-262966c63180@prevas.dk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 19, 2018 at 10:58:27PM +0100, Rasmus Villemoes wrote:
> On 2018-01-19 15:54, Arnd Bergmann wrote:
> > There is now only one caller left for svcxdr_dupstr() and this is inside
> > of an #ifdef, so we can get a warning when the option is disabled:
> > 
> > fs/nfsd/nfs4xdr.c:241:1: error: 'svcxdr_dupstr' defined but not used [-Werror=unused-function]
> > 
> > This adds another #ifdef around the definition.
> 
> Why not instead do
> 
> -#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
> -       if (bmval[2] & FATTR4_WORD2_SECURITY_LABEL) {
> +       if (IS_ENABLED(CONFIG_NFSD_V4_SECURITY_LABEL) && bmval[2] &
> FATTR4_WORD2_SECURITY_LABEL)
> 
> (sorry for whitespace damage, not a real patch).

That'd be OK with me too.

--b.
