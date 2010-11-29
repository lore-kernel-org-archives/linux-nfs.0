Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:38453 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753306Ab0K2WJj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Nov 2010 17:09:39 -0500
Received: by vws3 with SMTP id 3so151633vws.19
        for <linux-nfs@vger.kernel.org>; Mon, 29 Nov 2010 14:09:39 -0800 (PST)
Message-ID: <4CF4249F.9070400@garzik.org>
Date: Mon, 29 Nov 2010 17:09:35 -0500
From: Jeff Garzik <jeff@garzik.org>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>,
        sfaibish <sfaibish@emc.com>
Subject: Re: Block layout rpm
References: <20101129210708.GA21682@merit.edu>
In-Reply-To: <20101129210708.GA21682@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 11/29/2010 04:07 PM, Jim Rees wrote:
> I have released a developer's snapshot Fedora rpm of nfs-utils for the pnfs
> block layout client, at:
> http://www.citi.umich.edu/projects/nfsv4/pnfs/block/
>
> Instructions, as always, are on the wiki:
> http://wiki.linux-nfs.org/wiki/index.php/Fedora_pNFS_Client_Setup

"pNFS will work with 32-bit linux and lesser hardware, but the you will 
not obtain the performance benefits of pNFS."

That's just silly, and, I might even go so far as to say "wrong".  The 
benefits of direct-to-storage access, without an MDS middle-man, are 
quite noticable even for 32-bit, underpowered, and/or embedded clients.

	Jeff


