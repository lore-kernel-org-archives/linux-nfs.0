Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:45341 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751098AbaLRPgA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Dec 2014 10:36:00 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1Y1d7N-0005Km-5D
	for linux-nfs@vger.kernel.org; Thu, 18 Dec 2014 16:35:57 +0100
Received: from p4ff58315.dip0.t-ipconnect.de ([79.245.131.21])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 18 Dec 2014 16:35:57 +0100
Received: from holger.hoffstaette by p4ff58315.dip0.t-ipconnect.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 18 Dec 2014 16:35:57 +0100
To: linux-nfs@vger.kernel.org
From: Holger =?iso-8859-1?q?Hoffst=E4tte?=
	<holger.hoffstaette@googlemail.com>
Subject: Re: 3.18.1: broken directory with one file too many
Date: Thu, 18 Dec 2014 15:35:45 +0000 (UTC)
Message-ID: <pan.2014.12.18.15.35.45@googlemail.com>
References: <pan.2014.12.16.22.19.18@googlemail.com>
	<20141217212159.GA11517@fieldses.org> <5492C710.20104@googlemail.com>
	<20141218144856.GA18179@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 18 Dec 2014 09:48:56 -0500, J. Bruce Fields wrote:

> On a quick skim, the server's READDIR responses look correct.  The entry
> btrfs-20141216-fix-a-warning-of-qgroup-account-on-shared-extents.patch
> is returned in frame 53 (with complete reassembled reply displayed by
> wireshark in frame 63).
> 
> You could double-check for me--just run "wireshark nfs-server.pcap",
> look for packets labeled "Reply ... READDIR", and expand out the READDIR
> op and directory listing.  I don't see anything obviously wrong.

That's what I can see in Wireshark as well (#53 as part of the "20 
reassembled segments"). As I said in my followup I don't think there is 
anything wrong with that particular file since removing others "fixed" 
the problem. That's why I suspected NIC/TCP buggery, and since my kernels 
usually have a bunch of patches (the ones in that repo) I wanted to try 
vanilla 3.18.0/1 as well as -3.14.27 first.

>> Meanwhile I'll try older/plain (unpatched) kernels. So far reverting
>> the client to vanilla 3.18.1 or 3.14.27 has not helped..
> 
> I'm a little unclear: when you said "All this is on freshly baked
> 3.18.1", are you describing the client, or the server, or both?

That was on both. As I wrote in the followups I've now also tried to
first downgrade the clients (didn't help) and then finally found that
3.14.27 (both with and without my patches) on the server repeatably 
works, regardless of client. Right now I have 3.18.1 as clients and 
3.14.27 on the server, and that works fine.

I never noticed any other problems when first testing 3.18, which is why 
switched over all machines; it has been working really well so far.
No other networking problems, and I use NFS all day long. If there really 
was NIC packet corruption, NFS dropped requests or general page cache 
borkage then I think I would have noticed something much earlier.

Maybe you can try to reproduce? Try git clone https://github.com/
hhoffstaette/kernel-patches and rewind to rev e7b720ef after which I 
first noticed the problem. Then look at the 3.14 directory over NFS.

Let me know if there is anything else I can try!

regards,
Holger

