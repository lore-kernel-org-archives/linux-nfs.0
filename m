Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44542 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752863Ab0FGS3u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jun 2010 14:29:50 -0400
Date: Mon, 7 Jun 2010 14:29:48 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: sfaibish <sfaibish@emc.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Performance results with exofs
Message-ID: <20100607182948.GF25257@fieldses.org>
References: <op.vdxrrgf1unckof@usensfaibisl2e.eng.emc.com> <4C0D195B.8030401@panasas.com> <4C0D1AAB.4070304@panasas.com> <op.vdxxhfqsunckof@usensfaibisl2e.eng.emc.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <op.vdxxhfqsunckof@usensfaibisl2e.eng.emc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

>> On 06/07/2010 07:07 PM, Boaz Harrosh wrote:
>>> I did not yet publish the Document. It's stuck behind my dis-talent for
>>> writing and the pnfs bugs de jur.

Untalented writing we can fix, as long as the details are there!

>>>
>>> Basically all machines:
>>> - connected by a 1 GBit link.
>>> - All clients doing a dd write of 8GB file from /dev/zero
>>> - 3of8 is the special raid-groups arrangement of exofs && objlayout
>>>   where out of 8 devices each file is striped over 3 devices in a
>>>   round robin fashion. (*With a small dirty trick)

Random stupid questions:

	- why do you think the 3of8 arrangement is scaling better than
	  the 8of8?
	- Have you tried any other workloads?  (Perfectly reasonable
	  that simple write throughput would be the first thing to
	  check--I'm just curious.)

>>>
>>
>> - All tests over an *empty* filesystem.
>>
>>> [single client]
>>> 1 - osds 40MB
>>> 2 - osds 80MB
>>> 4 - osds 114MB (saturation point of the 1 Gbit link)
>>> 8 - osds 114MB
>>>
>>> [2 clients 8of8 osds]
>>> 226 MBs
>>>
>>> [4 clients 8of8 osds]
>>> 263 MBs
>>>
>>> [8 clients 8of8 osds]
>>> 252 MBs
>>>
>>> [1 clients 3of8 osds]
>>> 114 MBs
>>>
>>> [2 clients 3of8 osds *]
>>> 226 MBs
>>>
>>> [4 clients 3of8 osds *]
>>> 417 MBs

If each osd has a single gigabit interface, and you're striping to 3, of
them, isn't that 417/3 == 139 MB/s each?

(Oh, I see: you must be writing to a different file from each client,
hence you are using all osd's even if each client is only using 3?)

--b.

>>>
>>> [8 clients 3of8 osds]
>>> 405 MBs
