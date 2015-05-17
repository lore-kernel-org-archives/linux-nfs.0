Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [198.137.202.9] ([198.137.202.9]:37558 "EHLO
	bombadil.infradead.org" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750792AbbEQQjD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 17 May 2015 12:39:03 -0400
Date: Sun, 17 May 2015 09:38:41 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benjamin ESTRABAUD <be@mpstor.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bc@mpstor.com" <bc@mpstor.com>
Subject: Re: Issue running buffered writes to a pNFS (NFS 4.1 backed by SAN)
 filesystem.
Message-ID: <20150517163841.GA19109@infradead.org>
References: <41EB9782-8445-4FBB-A825-A484EFF7169C@mpstor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <41EB9782-8445-4FBB-A825-A484EFF7169C@mpstor.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Benjamin,

do you also see the issue with a Linux 4.0 client, or with latest
Linux tree (including commit 869a249123ac117b9995dc9e534644084b8c6321)?

