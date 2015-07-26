Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:38469 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755206AbbGZRkJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Jul 2015 13:40:09 -0400
Received: by wibxm9 with SMTP id xm9so88753333wib.1
        for <linux-nfs@vger.kernel.org>; Sun, 26 Jul 2015 10:40:07 -0700 (PDT)
Subject: Re: [PATCH V6 6/9] isert: Rename IO functions to more descriptive
 names
To: Steve Wise <swise@opengridcomputing.com>,
        Christoph Hellwig <hch@infradead.org>
References: <20150724161331.25617.8475.stgit@build2.ogc.int>
 <20150724161848.25617.26092.stgit@build2.ogc.int>
 <55B4B190.7070305@dev.mellanox.co.il> <20150726104328.GB18944@infradead.org>
 <55B4BDE3.8040801@dev.mellanox.co.il>
 <55B519C6.2030205@opengridcomputing.com>
Cc: dledford@redhat.com, infinipath@intel.com, sagig@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, linux-rdma@vger.kernel.org,
        eli@mellanox.com, target-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, bfields@fieldses.org
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <55B51B7A.8030008@dev.mellanox.co.il>
Date: Sun, 26 Jul 2015 20:40:10 +0300
MIME-Version: 1.0
In-Reply-To: <55B519C6.2030205@opengridcomputing.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


>> Ideally, the post contains a chain of all 4 registrations and the
>> rdma_read (and an opportunistic good scsi response).
>
> Just to be clear: This example is for IB only, correct?  IW would
> require rkeys with REMOTE_WRITE and 4 read wrs.

My assumption is that it would depend on max_sge_rd.

IB only? iWARP by definition isn't capable of doing rdma_read to
more than one scatter? Anyway, we'll need to calculate the number
of RDMA_READs.

> And you're ignoring invalidation wrs (or read-with-inv) in the example...

Yes, didn't want to inflate the example too much...
