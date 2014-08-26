Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f179.google.com ([209.85.212.179]:64691 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751665AbaHZPCa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Aug 2014 11:02:30 -0400
Received: by mail-wi0-f179.google.com with SMTP id f8so4321037wiw.0
        for <linux-nfs@vger.kernel.org>; Tue, 26 Aug 2014 08:02:29 -0700 (PDT)
Message-ID: <53FCA183.8000605@plexistor.com>
Date: Tue, 26 Aug 2014 18:02:27 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <matt@linuxbox.com>,
        "Adam C. Emerson" <aemerson@linuxbox.com>
Subject: Re: [PATCH] pnfs: Kick a pnfs_layoutcommit_inode on recall
References: <1408637375-11343-1-git-send-email-hch@lst.de>	<1408637375-11343-4-git-send-email-hch@lst.de>	<53FA259C.9050807@gmail.com>	<20140824191839.GA9717@lst.de>	<53FC9545.4000800@plexistor.com>	<CAHQdGtQNDvofWVzn9CmtmbDRSj39BLT_gNDyY34uUFw_nEDe0Q@mail.gmail.com>	<53FC9BB1.2020007@plexistor.com> <CAHQdGtQh76S-KXTESkmUCF7kSVEwTpJpL-5Cwog7xxE=M5u3mA@mail.gmail.com>
In-Reply-To: <CAHQdGtQh76S-KXTESkmUCF7kSVEwTpJpL-5Cwog7xxE=M5u3mA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/26/2014 05:55 PM, Trond Myklebust wrote:
> On Tue, Aug 26, 2014 at 10:37 AM, Boaz Harrosh <boaz@plexistor.com> wrote:
> 
> The above can deadlock if there are no session slots available to send
> the layoutcommit, in which case the recall won't complete, and the
> layoutget won't get a reply (which would free up the slot).
> 

What? the back-channel and the fore-channel do not use the same
slots. these are two different slots, No?

Matt, Adam you need to chip in here.

If it is as you say, then yes it must be as Christoph wrote it.

And the Ganesha server must be fixed because it has a slot system per
channel.

Thanks
Boaz

