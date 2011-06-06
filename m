Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:53404 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754441Ab1FFUMw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jun 2011 16:12:52 -0400
Received: by ywe9 with SMTP id 9so1620060ywe.19
        for <linux-nfs@vger.kernel.org>; Mon, 06 Jun 2011 13:12:51 -0700 (PDT)
In-Reply-To: <3FA034197108F04082D2AE1401CE0F3832A9B34E@VICMAILBOX.pronto.com.au>
References: <3FA034197108F04082D2AE1401CE0F3832A9B34E@VICMAILBOX.pronto.com.au>
Date: Mon, 6 Jun 2011 13:12:51 -0700
Message-ID: <BANLkTi=4ey0YpTtUwuVuRQz4_xYpt10wuw@mail.gmail.com>
Subject: Re: NFS Sync with External Journal
From: Wendy Cheng <s.wendy.cheng@gmail.com>
To: Tristan Ball <tristanb@pronto.com.au>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

You'll probably get better answer(s) from ext3 user mailing list
.... it is more about how journaling works for the specific file
system.

In ext3 case, I believe "sync" forces data getting flushed to the file
system *regardless* which journal mode is chosen. Using an external
journal device, particularly on SSD,  does help but the performance
gain is limited by the amount of data that needs to be written into
the file system itself.

-- Wendy

On Mon, Jun 6, 2011 at 6:42 AM, Tristan Ball <tristanb@pronto.com.au> wrote:
> Hi,
>
> I've been experimenting with using an external ext3 journal as a way to bring the write performance of an NFS share exported with the the 'sync' option closer to that of one exported with 'async'.
> I've mounted the ext3 filesystem with data=journal, and the journal itself is on SSD.  I've seen various references on the net saying that this should improve performance, as the nfs process can respond to write requests as soon as the data is in journal, rather than flushed all the way to the filesystem
>
> However, in my tests is seems that when the filesystem is shared as 'sync', then writes are written to the filesystem at the same time as they are written to the journal, and performance isn't significantly different to a plain ext3 filesystem with an internal journal and data=ordered. To me this implies that the NFS layer isn't returning from writes until they're flushed to the filesystem disk?
>
> So, my question really is - should I be expecting this to work as a performance enhancer?
>
> I realise that the server is doing more work with data=journal, however given how much faster than the HD the SSD is, and the fact that the journal is large enough to contain all the data I'm writing in this test, I was hoping to see the nfs writes occur at closer to wirespeed.
>
> Server is Oracle Linux, Kernel 2.6.32-100.28.5.el6.x86_64.
> Client was Ubuntu, 2.6.32-32-server x86_64.
>
> /etc/exports:
> /plain          *(rw,async,no_subtree_check,no_root_squash)
> /split          *(rw,async,no_subtree_check,no_root_squash) # (FS with external Journal)
>
> Client mounts were done simply with -o 'rw,rsize=32768,wsize=32768'
>
> Benchmark results:
> Plain Ext3, data=ordered export=sync, write speed 56-62MB/sec
> Split Ext3, data=journal export=sync, write speed = 46-50MB/sec
>
> For reference:
> Plain Ext3, data=ordered export=async, write speed 111MB/sec
> Split Ext3, data=journal export=async, write speed 110MB/sec
>
> Thanks for your time.
>
> Tristan
>
>
> Tristan Ball - Hosted Services Manager VIC
> Pronto Hosted Services
> 20 Lakeside Drive, Burwood East, VIC 3151
> Phone: +61 3 9887 7770 | Email: tristanb@pronto.com.au
> Mobile: +61 408 397 473
>
>
> For PHS helpdesk support, please email phs@pronto.com.au
> For urgent after hours support phone: 1800 622 556
>
> ---Legal Notice---
> The email message and any attachments are confidential and subject to copyright. If you are not the intended recipient, any use, interference with, disclosure or copying of this material is unauthorised and prohibited. No part may be reproduced, adapted or transmitted without the written permission of the copyright owner. If you have received this email in error, please immediately advise the sender by return email and delete the message from your system. Before opening or using attachments, check for viruses and defects. Our liability is limited to re-supplying any affected attachments.
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
