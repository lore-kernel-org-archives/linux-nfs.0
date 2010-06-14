From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: pNFS timeouts
Date: Mon, 14 Jun 2010 10:11:30 -0400
Message-ID: <4C163892.20201@panasas.com>
References: <20100614085157.GS17703@ics.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:37435 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753276Ab0FNOLa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jun 2010 10:11:30 -0400
In-Reply-To: <20100614085157.GS17703@ics.muni.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 14, 2010, 4:51 -0400, Lukas Hejtmanek <xhejtman@ics.muni.cz> wrote:
> Hi,
> 
> I'm playing with pNFS (spnfs layouts) using one MDS and one DS. I have
> a client that mount pNFS volume. 
> 
> I can touch (create) files on that volume immediately:
> time touch c
> 
> real    0m0.005s
> user    0m0.000s
> sys     0m0.000s
> 
> But creating files with a content suffers from approx. 15 secs timeout:
> 
> dd if=/dev/zero of=testf10 bs=1M count=1 
> 1+0 records in
> 1+0 records out
> 1048576 bytes (1.0 MB) copied, 15.1156 s, 69.4 kB/s
> 
> overwriting the same file works OK:
> 
> dd if=/dev/zero of=testf10 bs=1M count=1
> 1+0 records in
> 1+0 records out
> 1048576 bytes (1.0 MB) copied, 0.0258294 s, 40.6 MB/s
> 
> I think this is an interesting part of the debug logs:
> [69615.791232] pnfs_writeback_done: Begin (status -10008)

I'm not sure if that explains the 15 seconds delay.
I wonder if it could be related to the nfsv4 grace period.
Does this happen if you wait for a couple minutes after
the server restarts before starting the test?

Benny

> [69615.791238] put_lseg: lseg ffff88003b987840 ref 7 valid 1
> [69615.794450] NFS:  6195 nfs_writeback_done (status -10008 count 8192)
> [69615.794450] pnfs4_write_done DS write
> [69615.794450] nfs41_sequence_done: Error 0 free the slot 
> [69615.794450] nfs4_free_slot: free_slotid 0 highest_used_slotid 5
> [69615.794450] <-- pnfs4_write_done status= -11
> [69615.990137] filelayout_write_call_done new off 8192 orig offset 8192
> 
> Any ideas? 
> 
