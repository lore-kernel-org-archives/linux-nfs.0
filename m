From: "saeed bishara" <saeed.bishara@gmail.com>
Subject: Re: [NFS] read-ahead in NFS server
Date: Mon, 31 Dec 2007 15:43:10 +0200
Message-ID: <c70ff3ad0712310543n6f4f7562g355582c5f101b0e7@mail.gmail.com>
References: <c70ff3ad0712250734u2f9512f8j1e04f1179a4e2616@mail.gmail.com>
	<47787129.7060809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Dean Hildebrand" <seattleplus@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:43256 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751153AbXLaNnX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Dec 2007 08:43:23 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1J9KvI-0008WR-Ro
	for linux-nfs@vger.kernel.org; Tue, 01 Jan 2008 00:43:20 +1100
In-Reply-To: <47787129.7060809@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>
> I believe ext3 uses the standard linux readahead mechanism, so readahead
> should be occurring.  How are you determining on the server that ext3 is
> only issuing 32KB requests to the disks?
I use sar -du to see the actual requests average size that handled by
the sata driver.

 I bet that the nfs server is
> passing 32 KB requests to ext3, which in turn is issuing larger requests
> to the disks.
>
> Another thing to do is on linux you can increase the rsize to 1 MB to
> get larger chunks out of the disks.
it seems this is known issue with NFSv3 that is resolved in version 4,
please see my commit to the linux kernel mailing list:

http://lkml.org/lkml/2007/12/27/172

thanks
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

