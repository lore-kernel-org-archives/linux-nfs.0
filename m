Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:51525 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933787AbcHaNh1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Aug 2016 09:37:27 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux Network Devel Mailing <netdev@vger.kernel.org>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        List Linux Kernel Mailing <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 1/2] NFSv4.1: work around -Wmaybe-uninitialized warning
Date: Wed, 31 Aug 2016 15:37:28 +0200
Message-ID: <5024842.0SZmq2hZxe@wuerfel>
In-Reply-To: <9F99A562-A4F6-457A-A78F-44BAC3B5734F@primarydata.com>
References: <20160831123911.3467676-1-arnd@arndb.de> <9F99A562-A4F6-457A-A78F-44BAC3B5734F@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday, August 31, 2016 1:17:48 PM CEST Trond Myklebust wrote:
> What version of gcc are you using? I’m unable to reproduce with gcc 6.1.1..

This is also on 6.1.1 for ARM. Note that 6e8d666e9253 ("Disable
"maybe-uninitialized" warning globally") turned off those warnings, so
unless you explicitly pass -Wmaybe-uninitialized (e.g. by building with
"make W=1"), you won't get it.

The reason I'm still sending the patches for this warning is that
we do get a number of valid ones (this was the only false positive
out of the seven such warnings since last week).

	Arnd
