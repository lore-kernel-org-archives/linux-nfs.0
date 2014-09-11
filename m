Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f50.google.com ([209.85.192.50]:65138 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755430AbaIKOvk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Sep 2014 10:51:40 -0400
Received: by mail-qg0-f50.google.com with SMTP id z60so5455055qgd.23
        for <linux-nfs@vger.kernel.org>; Thu, 11 Sep 2014 07:51:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1410395791-2385-5-git-send-email-hch@lst.de>
References: <1410395791-2385-1-git-send-email-hch@lst.de> <1410395791-2385-5-git-send-email-hch@lst.de>
From: Peng Tao <bergwolf@primarydata.com>
Date: Thu, 11 Sep 2014 22:51:17 +0800
Message-ID: <CAKVebiWqxFF8GO4kkVr7AtO0gTC+o1Zb0QpfU4wC_oSAoeG-AQ@mail.gmail.com>
Subject: Re: [PATCH 4/4] pnfs: remove GETDEVICELIST implementation
To: Christoph Hellwig <hch@lst.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 11, 2014 at 8:36 AM, Christoph Hellwig <hch@lst.de> wrote:
> The current GETDEVICELIST implementation is buggy in that it doesn't handle
> cursors correctly, and in that it returns an error if the server returns
> NFSERR_NOTSUPP.  Given that there is no actual need for GETDEVICELIST,
> it has various issues and might get removed for NFSv4.2 stop using it in
> the blocklayout driver, and thus the Linux NFS client as whole.
>
I am missing patch 3/4, which I assume would fill in the gap where
GETDEVICEINFO is sent for block layout. Can you please resent that?

Cheers,
Tao
