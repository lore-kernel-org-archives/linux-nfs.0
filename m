From: "John Z. Bohach" <jzb2-t97x8lR6yknby3iVrkZq2A@public.gmane.org>
Subject: can't modify /etc/exports without blowing away existing clients
Date: Mon, 16 Feb 2009 12:20:20 -0800
Message-ID: <200902161220.20474.jzb2@aexorsyst.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Cc: "John Z. Bohach" <jzb2-t97x8lR6yknby3iVrkZq2A@public.gmane.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from host671420017099.direcway.com ([67.142.99.170]:60056 "EHLO
	aexorsyst.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752210AbZBPU2n (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Feb 2009 15:28:43 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

When I modify /etc/exports and re-run exportfs -a -r, newly 
added/removed/modified entries take effect, EXCEPT that all existing 
clients lose their current mounts.  Existing clients have to umount 
then mount NFS filesystems that were not even modified.

Is this intentional behavior?  If I try to manually add a new directory 
for export, and just use "exportfs -i ..." and specify the new 
directory to export that way, all existing entries in /etc/exports are 
gratuitously UNexported, all clients lose their current mounts, and 
only the one entry specified via the command line of "exportfs -i ..." 
is exported.  This doesn't seem like intentional behavior?  Or is it 
just the exportfs program that's broken?

I'm running linux-2.6.24.4 and using exportfs from nfs-utils-1.1.3 
though I've noticed this behavior on older versions of both.

Is there some NFS option I'm supposed to use in /etc/fstab on the 
clients to keep this remount thing from being necessary?  I'm pretty 
sure I tried both soft and hard mounts.  I'm currently using TCP as the 
mount transport layer...would UDP fix this issue, I haven't tested 
that...either way, even with TCP, it would be a big blow against using 
TCP as the mount transport if umount/mount sequence was required on the 
clients everytime time the server re-ran exportfs, which is what is 
happening now.

Anybody know what's going on?

Thanks,

John

P.S.:  Please keep me in the CC list, I'm not subscribed to the list.
