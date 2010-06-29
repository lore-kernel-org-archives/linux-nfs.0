From: "Halevy, Benny" <bhalevy@panasas.com>
Subject: RE: [pnfs]pnfs functions procedure
Date: Tue, 29 Jun 2010 05:22:52 -0400
Message-ID: <7225594ED4A1304C9E43D030A886D221F4C96E@daytona.int.panasas.com>
References: <AANLkTikdp54iyeqpCKRNce2YDZJ2UEuuSpMp6yj2p15A@mail.gmail.com><7225594ED4A1304C9E43D030A886D221F4C96C@daytona.int.panasas.com> <AANLkTimXMzj5e-XelyG8Z6-bmmaZhuQTHE-eXI-b2OOl@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: <linux-nfs@vger.kernel.org>
To: "quanli gui" <gqlxj1987@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:54737 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754685Ab0F2JWy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jun 2010 05:22:54 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At the protocol level the write will require a layout
and device information so that the client can map the
byte offsets in the file to the particular devices.

So, in case the client does not have this information in
its cache it may issue a LAYOUTGET to the metadata server.

This happens in _pnfs_update_layout() which is currently
being called from nfs_write_begin() (which essentially
happens when the application data enters the client's
cache)

For any new device id mentioned in the layout,
the layout driver will issue a GETDEVICEINFO
to populate the device cache.  For example
see this path:
filelayout_alloc_lseg
filelayout_check_layout
get_device_info.

Eventually, when the data is flushed onto the storage
the client and layout driver use the cached layout to
write and commit the data to the data servers.

See for example:
nfs_writepage
nfs_writepage_locked
nfs_pageio_init_write
nfs_pageio_init(... nfs_flush_multi)
nfs_flush_multi
nfs_write_rpcsetup
pnfs_initiate_write
pnfs_try_to_write_data
_pnfs_try_to_write_data
pnfs_writepages
nfss->pnfs_curr_ld->ld_io_ops->write_pagelist()

Which is, for example in the files layout case:
filelayout_write_pagelist
that in turn, calls nfs_initiate_write for the data server serving the byte offset

later COMMIT (or the equivalent for the particular layout driver)
may be called to commit the written data to non-volatile storage
and LAYOUTCOMMIT is sent to the metadata server

A code path that issues this, for example, starts in
nfs_write_inode

I hope this helps!

Benny

-----Original Message-----
From: quanli gui [mailto:gqlxj1987@gmail.com]
Sent: Tue 2010-06-29 10:58
To: Halevy, Benny
Subject: Re: [pnfs]pnfs functions procedure
 
I means that for example, when i want to write a file, how pnfs handle this
write file command? It would treat this command with which functions in
pnfs. how is the functions procedure?

2010/6/29 Halevy, Benny <bhalevy@panasas.com>

> Dear Quanli,
>
> I'm not sure what you meant exactly from your message
> so we'll have to close the language barrier somehow.
> (I'm not a native English speaker as well ;-))
>
> It would help if you can please provide a concrete
> example of a simple thing you want to accomplish
> so we can focus on how to help you achieve that.
>
> Thanks,
>
> Benny
>
> -----Original Message-----
> From: quanli gui [mailto:gqlxj1987@gmail.com]
> Sent: Tue 2010-06-29 05:07
> To: linux-pnfs
> Cc: Halevy, Benny
> Subject: [pnfs]pnfs functions procedure
>
> For pnfs, I nearly know every function, that means that i almost know the
> meanings of the function. But i don't know how to  tandem these functions.
> I
> don't know in fact i use which function when i use pnfs. I don't know how
> to
> connect the function to the defacto use. When i  use pnfs setup by setup,
> the functions procedure? I don't know. I hope that someone can give me
> something about this. Thanks.
>
>

