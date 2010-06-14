From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: pNFS timeouts
Date: Mon, 14 Jun 2010 10:51:57 +0200
Message-ID: <20100614085157.GS17703@ics.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:46807 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755531Ab0FNIv5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jun 2010 04:51:57 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I'm playing with pNFS (spnfs layouts) using one MDS and one DS. I have
a client that mount pNFS volume.=20

I can touch (create) files on that volume immediately:
time touch c

real    0m0.005s
user    0m0.000s
sys     0m0.000s

But creating files with a content suffers from approx. 15 secs timeout:

dd if=3D/dev/zero of=3Dtestf10 bs=3D1M count=3D1=20
1+0 records in
1+0 records out
1048576 bytes (1.0 MB) copied, 15.1156 s, 69.4 kB/s

overwriting the same file works OK:

dd if=3D/dev/zero of=3Dtestf10 bs=3D1M count=3D1
1+0 records in
1+0 records out
1048576 bytes (1.0 MB) copied, 0.0258294 s, 40.6 MB/s

I think this is an interesting part of the debug logs:
[69615.791232] pnfs_writeback_done: Begin (status -10008)
[69615.791238] put_lseg: lseg ffff88003b987840 ref 7 valid 1
[69615.794450] NFS:  6195 nfs_writeback_done (status -10008 count 8192)
[69615.794450] pnfs4_write_done DS write
[69615.794450] nfs41_sequence_done: Error 0 free the slot=20
[69615.794450] nfs4_free_slot: free_slotid 0 highest_used_slotid 5
[69615.794450] <-- pnfs4_write_done status=3D -11
[69615.990137] filelayout_write_call_done new off 8192 orig offset 8192

Any ideas?=20

--=20
Luk=E1=B9 Hejtm=E1nek
