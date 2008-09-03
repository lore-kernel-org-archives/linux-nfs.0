From: Ricardo Santos <xscorpionbr-/E1597aS9LRfJ/NunPodnw@public.gmane.org>
Subject: Re: directory attribute cache on NFS4 client
Date: Wed, 3 Sep 2008 02:57:53 +0000 (UTC)
Message-ID: <loom.20080903T025252-10@post.gmane.org>
References: <loom.20080829T132559-688@post.gmane.org> <loom.20080901T163528-489@post.gmane.org> <20080902175047.GA10855@fieldses.org> <loom.20080902T195042-521@post.gmane.org> <Pine.BSO.4.64.0809021610460.7435@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:43007 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752091AbYICC6I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Sep 2008 22:58:08 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1KaiZH-0002HF-Cx
	for linux-nfs@vger.kernel.org; Wed, 03 Sep 2008 02:58:03 +0000
Received: from bd22caa7.virtua.com.br ([bd22caa7.virtua.com.br])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 03 Sep 2008 02:58:03 +0000
Received: from xscorpionbr by bd22caa7.virtua.com.br with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 03 Sep 2008 02:58:03 +0000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> yes, you can echo 0 to /proc/sys/fs/leases-enable
> 
> note that that disables all leases (atop which NFS delegations are 
> implemented).

david, thanks for the tip. It really works for me!

