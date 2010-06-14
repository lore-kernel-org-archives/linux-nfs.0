From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: pNFS timeouts
Date: Mon, 14 Jun 2010 11:10:53 -0400
Message-ID: <4C16467D.2030000@panasas.com>
References: <20100614085157.GS17703@ics.muni.cz> <4C163892.20201@panasas.com> <20100614142332.GB17703@ics.muni.cz> <4C1640DF.5070506@panasas.com> <20100614150542.GD17703@ics.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:24481 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752038Ab0FNPKx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jun 2010 11:10:53 -0400
In-Reply-To: <20100614150542.GD17703@ics.muni.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 14, 2010, 11:05 -0400, Lukas Hejtmanek <xhejtman@ics.muni.cz> wrote:
> On Mon, Jun 14, 2010 at 10:46:55AM -0400, Benny Halevy wrote:
>>> Jun 14 16:17:00 undomiel1 kernel: [187434.936507] nfs41_sequence_call_done rpc_cred ffff88003d7a0300
>>> Jun 14 16:17:00 undomiel1 kernel: [187434.936514] <-- nfs41_sequence_call_done
>>> Jun 14 16:17:00 undomiel1 kernel: [187434.936522] nfs4_schedule_state_renewal: requeueing work. Lease period = 60
>>> Jun 14 16:17:00 undomiel1 kernel: [187434.936530] --> nfs_put_client({2})
>>> Jun 14 16:17:16 undomiel1 kernel: [187450.536014] nfs4_renew_state: start
>>> Jun 14 16:17:16 undomiel1 kernel: [187450.536045] nfs4_renew_state: failed to call renewd. Reason: lease not expired
>>> Jun 14 16:17:16 undomiel1 kernel: [187450.536056] nfs4_schedule_state_renewal: requeueing work. Lease period = 38
>>
>> This looks like a complaint but it's actually saying that the "failure"
>> is due to the fact that everything is OK (lease not expired)
> 
> the state renewal actually starts after 16 seconds after schedule start
> renewal for some reason. The nfs_put_client actually starts the renewal?
> 

No, the state renewal is done independently in the background.

>> BTW, is this the same issue that Jiri reported?
>> http://marc.info/?l=linux-nfs&m=127619696004097&w=2
> 
> Yes, but I didn't see any response to that, so I guess his report is not clear
> enough.
> 
