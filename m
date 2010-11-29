Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:35333 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754954Ab0K2Wjo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Nov 2010 17:39:44 -0500
Received: by vws3 with SMTP id 3so166507vws.19
        for <linux-nfs@vger.kernel.org>; Mon, 29 Nov 2010 14:39:44 -0800 (PST)
Message-ID: <4CF42BAD.1060607@garzik.org>
Date: Mon, 29 Nov 2010 17:39:41 -0500
From: Jeff Garzik <jeff@garzik.org>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>,
        sfaibish <sfaibish@emc.com>
Subject: Re: Block layout rpm
References: <20101129210708.GA21682@merit.edu> <4CF4249F.9070400@garzik.org> <20101129222613.GA1210@merit.edu>
In-Reply-To: <20101129222613.GA1210@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 11/29/2010 05:26 PM, Jim Rees wrote:
> Jeff Garzik wrote:
>
>    "pNFS will work with 32-bit linux and lesser hardware, but the you
>    will not obtain the performance benefits of pNFS."
>
>    That's just silly, and, I might even go so far as to say "wrong".
>    The benefits of direct-to-storage access, without an MDS middle-man,
>    are quite noticable even for 32-bit, underpowered, and/or embedded
>    clients.
>
> Agreed.  It used to say 64-bit only, and I added the part about 32-bit
> because it does run on 32-bit, but really that should just come out.  I'll
> fix it.

Thanks.

I'd also say, with my networking hat on, the VLAN statement is 
unqualified.  VLAN is not necessary for pNFS, but the way the statement 
reads to me, I get the opposite impression.

pNFS works quite well if you're just a 1U client with a single NIC, for 
example.

	Jeff


