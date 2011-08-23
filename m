Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:37746 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752183Ab1HWV0U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Aug 2011 17:26:20 -0400
Message-ID: <4E541945.6@panasas.com>
Date: Tue, 23 Aug 2011 14:19:01 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Peng Tao <bergwolf@gmail.com>, "Isaman, Fred" <Fred.Isaman@netapp.com>,
        Andy Adamson <andros@netapp.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@tonian.com>, <linux-nfs@vger.kernel.org>,
        Peng Tao <peng_tao@emc.com>
Subject: Re: [PATCH] pnfsblock: init pg_bsize properly
References: <1313197450-4595-1-git-send-email-bergwolf@gmail.com> <4E4ADBA1.1000005@panasas.com> <4E4B6A81.2010204@tonian.com> <CA+a=Yy6BSmEWurZuFN-8axTS0gfeXaguw5tcayeVjJmcFAztOQ@mail.gmail.com> <4E52EBAC.8070908@panasas.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AC9DF79@SACMVEXC2-PRD.hq.netapp.com> <CA+a=Yy4gm3789v0w-dGpZO1w9RrpC7ELgeM9=qNsf4tYigdw2A@mail.gmail.com>
In-Reply-To: <CA+a=Yy4gm3789v0w-dGpZO1w9RrpC7ELgeM9=qNsf4tYigdw2A@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/23/2011 08:01 AM, Peng Tao wrote:
> So this is a generic issue. For file and object layout, do you need to
> use partial read/write rpc ops in any case? For block layout, we would
> like to never use it in LD. But I'm not sure about file and object
> case. Could you confirm?
> 

For objects it is like blocks. NEVER (ever) use partial rpc ops. r/wsize
are not relevant for obj-LD IO.

(As I understand from Trond also with files the LD should inspect the
 situation and have the final disposition. But someone will need to write
 some files-LD code for that, Fred, Andy?)

> Thanks,
> Tao

Thanks
Boaz
