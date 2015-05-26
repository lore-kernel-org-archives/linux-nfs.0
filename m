Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from outbound-smtp02.blacknight.com ([81.17.249.8]:52777 "EHLO
	outbound-smtp02.blacknight.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753354AbbEZQoq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 May 2015 12:44:46 -0400
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id A8B3D9848B
	for <linux-nfs@vger.kernel.org>; Tue, 26 May 2015 16:44:44 +0000 (UTC)
Message-ID: <5564A2FC.20809@mpstor.com>
Date: Tue, 26 May 2015 17:44:44 +0100
From: Benjamin ESTRABAUD <be@mpstor.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bc@mpstor.com" <bc@mpstor.com>
Subject: Re: Issue running buffered writes to a pNFS (NFS 4.1 backed by SAN)
 filesystem.
References: <41EB9782-8445-4FBB-A825-A484EFF7169C@mpstor.com> <20150517163841.GA19109@infradead.org> <555CB69B.7030108@mpstor.com> <20150525151429.GB18386@infradead.org>
In-Reply-To: <20150525151429.GB18386@infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 25/05/15 16:14, Christoph Hellwig wrote:
> On Wed, May 20, 2015 at 05:30:19PM +0100, Benjamin ESTRABAUD wrote:
>> I'm going to try this now (move client and maybe even server to Linux 4.0,
>> now that 4.0 has a more "current" stable release).
>
> Only the client is interesting in this case.
>
>> By the way, what is the minimum Linux Kernel version required to connect to
>> a NFS v4.1 server using pNFS? We only managed to get this working with
>> kernel 4.0 (on the client) and it appears that this is the lowest kernel
>> release that supports pNFS block clients (working with Linux pNFS recent
>> block server). Could you please confirm this?
>
> The big changes to make the block client useful went into 3.18.  Almost
> nothing has changed in the client since.
>
OK, we'll give 3.18 another shot (we had tried before without luck), but 
if not much as changed we're likely to see the problem also there. I'm 
going to also try running this test over a different SAN fabric (GbE 
instead of 40GbE and see if the issue still occurs).

Thanks,

Ben.
