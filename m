Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from outbound-smtp03.blacknight.com ([81.17.249.16]:40074 "EHLO
	outbound-smtp03.blacknight.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754346AbbETQaU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 May 2015 12:30:20 -0400
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 6081298D7A
	for <linux-nfs@vger.kernel.org>; Wed, 20 May 2015 16:30:19 +0000 (UTC)
Message-ID: <555CB69B.7030108@mpstor.com>
Date: Wed, 20 May 2015 17:30:19 +0100
From: Benjamin ESTRABAUD <be@mpstor.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bc@mpstor.com" <bc@mpstor.com>
Subject: Re: Issue running buffered writes to a pNFS (NFS 4.1 backed by SAN)
 filesystem.
References: <41EB9782-8445-4FBB-A825-A484EFF7169C@mpstor.com> <20150517163841.GA19109@infradead.org>
In-Reply-To: <20150517163841.GA19109@infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 17/05/15 17:38, Christoph Hellwig wrote:
> Hi Benjamin,
>
> do you also see the issue with a Linux 4.0 client, or with latest
> Linux tree (including commit 869a249123ac117b9995dc9e534644084b8c6321)?
>
>
Hi Christopher,

I'm going to try this now (move client and maybe even server to Linux 
4.0, now that 4.0 has a more "current" stable release).

By the way, what is the minimum Linux Kernel version required to connect 
to a NFS v4.1 server using pNFS? We only managed to get this working 
with kernel 4.0 (on the client) and it appears that this is the lowest 
kernel release that supports pNFS block clients (working with Linux pNFS 
recent block server). Could you please confirm this?

Regards,
Ben.
