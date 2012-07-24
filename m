Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31785 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753398Ab2GXTeJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Jul 2012 15:34:09 -0400
Date: Tue, 24 Jul 2012 12:33:49 -0700
From: "Haynes, Tom" <thomas@netapp.com>
To: bfields@fieldses.org, linux-nfs@vger.kernel.org, nfsv4@ietf.org
Subject: Constructing a NFSv4 ACL from POSIX mode bits
Message-ID: <20120724193348.GA4977@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce,

In looking at http://tools.ietf.org/html/draft-ietf-nfsv4-acl-mapping-05, it
states that when mapping the write bit, only for the owner do we set
ACE4_WRITE_ACL.

Back in version 00, it is open as to whether we can also set it for the
group and other if they have the write bit set.

I looked back at the NFSv4 WG aliases and I see some discussion from Lisa
on how Solaris only ever sets it for the owner due to POSIX restrictions
via chmod(). So, now I know how another server does it.

What does the Linux server do in this case?

Thanks,
Tom

-- 
thomas@netapp.com, ex-cfb
