From: Ricardo Santos <xscorpionbr-/E1597aS9LRfJ/NunPodnw@public.gmane.org>
Subject: Re: directory attribute cache on NFS4 client
Date: Mon, 1 Sep 2008 16:40:04 +0000 (UTC)
Message-ID: <loom.20080901T163528-489@post.gmane.org>
References: <loom.20080829T132559-688@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:41699 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751627AbYIAQkT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Sep 2008 12:40:19 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1KaCRq-00083U-8R
	for linux-nfs@vger.kernel.org; Mon, 01 Sep 2008 16:40:15 +0000
Received: from viper.litoral.com.br ([200.155.112.7])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Mon, 01 Sep 2008 16:40:14 +0000
Received: from xscorpionbr by viper.litoral.com.br with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Mon, 01 Sep 2008 16:40:14 +0000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm checking the NFS client code to understand it, and I saw this:

-- inode.c
int nfs_attribute_timeout(struct inode *inode)
{
        struct nfs_inode *nfsi = NFS_I(inode);

        if (nfs_have_delegation(inode, FMODE_READ))
                return 0;

--

So, if a inode has a delegation, will it never be timed out, until the
delegation been free, right ?

If the delegated inode has been deleted ?

