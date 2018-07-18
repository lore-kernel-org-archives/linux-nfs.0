Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.133]:41874 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729281AbeGRNKr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Jul 2018 09:10:47 -0400
Date: Wed, 18 Jul 2018 05:33:03 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] rpc.gssd: truncates 32-bit UIDs/GIDs to 16 bits
 architectures.
Message-ID: <20180718123303.GA2749@infradead.org>
References: <20180718121107.16838-1-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180718121107.16838-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -	if (syscall(SYS_setresgid, pw->pw_gid, pw->pw_gid, pw->pw_gid) != 0) {
> +#ifdef __NR_setresuid32
> +	res = syscall(SYS_setresgid32, pw->pw_gid, pw->pw_gid, pw->pw_gid);
> +#else 
> +	res = syscall(SYS_setresgid, pw->pw_gid, pw->pw_gid, pw->pw_gid);
> +#endif

I think you want to simply call setresuid/setresgid from glibcs, which
will do the right thing instead of doing hand crafted syscalls.
