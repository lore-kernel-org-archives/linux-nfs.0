From: "saeed bishara" <saeed.bishara@gmail.com>
Subject: [NFS] read-ahead in NFS server
Date: Tue, 25 Dec 2007 17:34:12 +0200
Message-ID: <c70ff3ad0712250734u2f9512f8j1e04f1179a4e2616@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: saeed bishara <saeed.bishara@gmail.com>
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:60109 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752927AbXL1JJD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Dec 2007 04:09:03 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1J8BD9-0004l1-NM
	for linux-nfs@vger.kernel.org; Fri, 28 Dec 2007 20:08:59 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,
my NFS server seems not to utilize the read-ahead feature, my exported
dir is located on ext3 fs over sata disk. the sata controller can
issue commands up to 1MB, also I modified the read ahead under the sys
to 1MB. but when the client do reads in 32KB chunks (rsize), I can see
in the server side that all IOs are ~32KB. my kernel version is
2.6.22.7.
does the NFS server utilizes the read-ahead feature? what should I do
to enable it?

please CC me as I'm not subscribed to this list.
saeed

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

