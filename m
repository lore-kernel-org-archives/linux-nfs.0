From: "Chris Fanning" <christopher.fanning@gmail.com>
Subject: [NFS] async vs. sync. corrupted fs
Date: Fri, 16 May 2008 12:55:59 +0200
Message-ID: <215ff4410805160355x25b8d055x9a0a246aa5875482@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:37675 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754943AbYEPMYN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 May 2008 08:24:13 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Jwyyn-0001g3-Rh
	for linux-nfs@vger.kernel.org; Fri, 16 May 2008 22:24:09 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello all,

Could someone help me out?

I'm exporting a whole partition to a client.
Using (rw,no_root_squash,sync, no_subtree_check), when I shutdown the
server _before_ the client, the filesystem on the partion becomes
corrupted.
When I user async, it doesn't happen.

Is this normal?
The exports manpage suggests that 'sync' is the better option.

Thanks.
Chris.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft 
Defy all challenges. Microsoft(R) Visual Studio 2008. 
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

