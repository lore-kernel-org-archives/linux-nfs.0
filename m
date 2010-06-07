Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:48607 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751767Ab0FGSoB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jun 2010 14:44:01 -0400
Message-ID: <4C0D3DEE.4020504@panasas.com>
Date: Mon, 07 Jun 2010 21:43:58 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: sfaibish <sfaibish@emc.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Performance results with exofs
References: <op.vdxrrgf1unckof@usensfaibisl2e.eng.emc.com> <4C0D195B.8030401@panasas.com> <4C0D1AAB.4070304@panasas.com> <op.vdxxhfqsunckof@usensfaibisl2e.eng.emc.com> <20100607182948.GF25257@fieldses.org>
In-Reply-To: <20100607182948.GF25257@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/07/2010 09:29 PM, J. Bruce Fields wrote:
>>>> [4 clients 3of8 osds *]
>>>> 417 MBs
> 
> If each osd has a single gigabit interface, and you're striping to 3, of
> them, isn't that 417/3 == 139 MB/s each?
> 
> (Oh, I see: you must be writing to a different file from each client,
> hence you are using all osd's even if each client is only using 3?)
> 

Right and that little trick from the previous email ;-)

Boaz
> --b.
> 
>>>>
>>>> [8 clients 3of8 osds]
>>>> 405 MBs

