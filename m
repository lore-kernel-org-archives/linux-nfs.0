Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:36451 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751547AbbIXGx1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Sep 2015 02:53:27 -0400
Received: by wicgb1 with SMTP id gb1so235974538wic.1
        for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2015 23:53:26 -0700 (PDT)
Subject: Re: [PATCH v1 00/24] New fast registration API
To: Christoph Hellwig <hch@infradead.org>, Sagi Grimberg <sagig@mellanox.com>
References: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
 <20150919224518.GA23027@infradead.org>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
        "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <56039DE9.1010300@dev.mellanox.co.il>
Date: Thu, 24 Sep 2015 09:53:29 +0300
MIME-Version: 1.0
In-Reply-To: <20150919224518.GA23027@infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 9/20/2015 1:45 AM, Christoph Hellwig wrote:
> Hi Sagi,
>
> I've converted the driver I'm developing to your API and it works
> great.  I think this is an important step towards making the RDMA
> more usable!

Thanks Christoph,

should I take it as your "Tested-by: " on ib_core + mlx4 changes?
