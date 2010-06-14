From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: pNFS timeouts
Date: Mon, 14 Jun 2010 10:46:55 -0400
Message-ID: <4C1640DF.5070506@panasas.com>
References: <20100614085157.GS17703@ics.muni.cz> <4C163892.20201@panasas.com> <20100614142332.GB17703@ics.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:19861 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754070Ab0FNOq5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jun 2010 10:46:57 -0400
In-Reply-To: <20100614142332.GB17703@ics.muni.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 14, 2010, 10:23 -0400, Lukas Hejtmanek <xhejtman@ics.muni.cz> wrote:
> Hi,
> 
> On Mon, Jun 14, 2010 at 10:11:30AM -0400, Benny Halevy wrote:
>> I'm not sure if that explains the 15 seconds delay.
>> I wonder if it could be related to the nfsv4 grace period.
>> Does this happen if you wait for a couple minutes after
>> the server restarts before starting the test?
> 
> I repeated the test after approx. 6 hours the server was restarted and it is
> the same, the delay still happens. 
> 
> But it could be something related, it complains about lease renewal:
> 
> Jun 14 16:17:00 undomiel1 kernel: [187434.936220] nfs4_renew_state: done
> Jun 14 16:17:00 undomiel1 kernel: [187434.936492] nfs41_sequence_done: Error 0 free the slot
> Jun 14 16:17:00 undomiel1 kernel: [187434.936500] nfs4_free_slot: free_slotid 0 highest_used_slotid -1
> Jun 14 16:17:00 undomiel1 kernel: [187434.936507] nfs41_sequence_call_done rpc_cred ffff88003d7a0300
> Jun 14 16:17:00 undomiel1 kernel: [187434.936514] <-- nfs41_sequence_call_done
> Jun 14 16:17:00 undomiel1 kernel: [187434.936522] nfs4_schedule_state_renewal: requeueing work. Lease period = 60
> Jun 14 16:17:00 undomiel1 kernel: [187434.936530] --> nfs_put_client({2})
> Jun 14 16:17:16 undomiel1 kernel: [187450.536014] nfs4_renew_state: start
> Jun 14 16:17:16 undomiel1 kernel: [187450.536045] nfs4_renew_state: failed to call renewd. Reason: lease not expired
> Jun 14 16:17:16 undomiel1 kernel: [187450.536056] nfs4_schedule_state_renewal: requeueing work. Lease period = 38

This looks like a complaint but it's actually saying that the "failure"
is due to the fact that everything is OK (lease not expired)

BTW, is this the same issue that Jiri reported?
http://marc.info/?l=linux-nfs&m=127619696004097&w=2

Benny

> 
> The full log can be found at:
> http://undomiel.ics.muni.cz/tmp/nfs-log.txt
> 
