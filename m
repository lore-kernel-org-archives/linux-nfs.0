Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f182.google.com ([74.125.82.182]:48513 "EHLO
	mail-we0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752114AbaHZSeJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Aug 2014 14:34:09 -0400
Received: by mail-we0-f182.google.com with SMTP id k48so15106865wev.41
        for <linux-nfs@vger.kernel.org>; Tue, 26 Aug 2014 11:34:08 -0700 (PDT)
Message-ID: <53FCD31D.9090705@gmail.com>
Date: Tue, 26 Aug 2014 21:34:05 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
To: Boaz Harrosh <boaz@plexistor.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: "Matt W. Benjamin" <matt@linuxbox.com>, Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "Adam C. Emerson" <aemerson@linuxbox.com>
Subject: Re: [PATCH] pnfs: Kick a pnfs_layoutcommit_inode on recall
References: <53FCA183.8000605@plexistor.com>	<1435166875.78.1409066662291.JavaMail.root@thunderbeast.private.linuxbox.com>	<CAHQdGtT-B7NTP8T7ETgTJD1+84k_KW_5aOfrYjLpA04hoR3YsA@mail.gmail.com>	<53FCBC5A.4060304@plexistor.com>	<CAHQdGtSghgbrPr=X8O2YLq=vXbKY1y5OuOMisf6vRoj8WeF0YA@mail.gmail.com>	<53FCBE9C.40906@plexistor.com> <CAHQdGtTgcGiWbcZyAsaOzdB=RpdUx17vHcw1yxg7vS56BfwY+A@mail.gmail.com> <53FCCFBD.3080305@plexistor.com>
In-Reply-To: <53FCCFBD.3080305@plexistor.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/26/2014 09:19 PM, Boaz Harrosh wrote:
<>
> Beep! but this is exactly what I'm trying to say. The STD specifically
> forbids that. The server is not allowed to wait here, it must return
> imitatively, with an error that frees the slot and then later issue the
> RECALL.
> 
> This is what I said exactly three times in my mail, and what I have
> depicted in my flow:
> 	Server async operation (mandated by the STD)
> 	Client back-channel can be sync with for channel (Not mentioned by the STD)
> 


BTW Both Ganesha and kpnfsd behave the same. A recall issued while in layout_get
the layout-get reply will be sent first and then the recall will be sent on the wire.

If the recall was sent before the receive of the layout_get then an error/success is
returned imitatively without ever waiting for recall_reply to return.

Thanks
Boaz

