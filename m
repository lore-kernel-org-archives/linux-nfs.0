Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:33546 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755328AbbI2Gtb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Sep 2015 02:49:31 -0400
Received: by wiclk2 with SMTP id lk2so135735764wic.0
        for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2015 23:49:30 -0700 (PDT)
Subject: Re: [PATCH v1 01/24] IB/core: Introduce new fast registration API
To: Sagi Grimberg <sagig@mellanox.com>, Christoph Hellwig <hch@infradead.org>,
        Bart Van Assche <bart.vanassche@sandisk.com>
References: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
 <1442482947-27785-2-git-send-email-sagig@mellanox.com>
 <5601C65F.8060403@sandisk.com> <5603A841.70509@dev.mellanox.co.il>
 <5609A9D0.8030607@sandisk.com> <20150929055907.GA29758@infradead.org>
 <560A341F.7030108@mellanox.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
        "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <560A3474.3040603@dev.mellanox.co.il>
Date: Tue, 29 Sep 2015 09:49:24 +0300
MIME-Version: 1.0
In-Reply-To: <560A341F.7030108@mellanox.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 9/29/2015 9:47 AM, Sagi Grimberg wrote:
>> Shouldn't higher layers take care of this?  Trying to implement the same
>> coalescing algorithm at various layers isn't very optimal, although we
>> need to decide and document which one is responsible.
>
> The block layer can take care of it, but I'm not sure about NFS/RDS at
> the moment (IIRC Steve specifically asked if this API would take care
> of chunking contig sg elements) so I'd rather keep it in until we are
> absolutely sure we don't need it.
>
> I can add a documentation statement for it.

Actually its documented:

  * Constraints:
  * - The first sg element is allowed to have an offset.
  * - Each sg element must be aligned to page_size (or physically
  *   contiguous to the previous element). In case an sg element has a
  *   non contiguous offset, the mapping prefix will not include it.
  * - The last sg element is allowed to have length less than page_size.

