Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-am1on0075.outbound.protection.outlook.com ([157.56.112.75]:37785
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755426AbbI2HEG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Sep 2015 03:04:06 -0400
Subject: Re: [PATCH v1 01/24] IB/core: Introduce new fast registration API
To: Christoph Hellwig <hch@infradead.org>,
        Bart Van Assche <bart.vanassche@sandisk.com>
References: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
 <1442482947-27785-2-git-send-email-sagig@mellanox.com>
 <5601C65F.8060403@sandisk.com> <5603A841.70509@dev.mellanox.co.il>
 <5609A9D0.8030607@sandisk.com> <20150929055907.GA29758@infradead.org>
CC: Sagi Grimberg <sagig@dev.mellanox.co.il>, <linux-rdma@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>,
        "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Sagi Grimberg <sagig@mellanox.com>
Message-ID: <560A341F.7030108@mellanox.com>
Date: Tue, 29 Sep 2015 09:47:59 +0300
MIME-Version: 1.0
In-Reply-To: <20150929055907.GA29758@infradead.org>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Shouldn't higher layers take care of this?  Trying to implement the same
> coalescing algorithm at various layers isn't very optimal, although we
> need to decide and document which one is responsible.

The block layer can take care of it, but I'm not sure about NFS/RDS at
the moment (IIRC Steve specifically asked if this API would take care
of chunking contig sg elements) so I'd rather keep it in until we are
absolutely sure we don't need it.

I can add a documentation statement for it.
