Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:60565 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756953Ab0HFOFr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Aug 2010 10:05:47 -0400
Received: by iwn33 with SMTP id 33so1351265iwn.19
        for <linux-nfs@vger.kernel.org>; Fri, 06 Aug 2010 07:05:47 -0700 (PDT)
In-Reply-To: <20100806132620.GA2921@merit.edu>
References: <4C5BFE47.8020905@mxtelecom.com>
	<20100806132620.GA2921@merit.edu>
Date: Fri, 6 Aug 2010 15:05:46 +0100
Message-ID: <AANLkTin_pg7GCw9jcB2JK+0TbGu+MrQEcv4H_qAg_A3H@mail.gmail.com>
Subject: Re: Tuning NFS client write pagecache
From: Peter Chacko <peterchacko35@gmail.com>
To: Jim Rees <rees@umich.edu>
Cc: Matthew Hodgson <matthew@mxtelecom.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Some distributed file systems such as IBM's SANFS, support direct IO
to the target storage....without going through a cache... ( This
feature is useful, for write only work load....say, we are backing up
huge data to an NFS share....).

I think if not available, we should add a DIO mount option, that tell
the VFS not to cache any data, so that close operation will not stall.

With the open-to-close , cache coherence protocol of NFS, an
aggressive caching client, is a performance downer for many work-loads
that is write-mostly.



On Fri, Aug 6, 2010 at 2:26 PM, Jim Rees <rees@umich.edu> wrote:
> Matthew Hodgson wrote:
>
>  Is there any way to tune the linux NFSv3 client to prefer to write
>  data straight to an async-mounted server, rather than having large
>  writes to a file stack up in the local pagecache before being synced
>  on close()?
>
> It's been a while since I've done this, but I think you can tune this with
> vm.dirty_writeback_centisecs and vm.dirty_background_ratio sysctls.  The
> data will still go through the page cache but you can reduce the amount that
> stacks up.
>
> There are other places where the data can get buffered, like the rpc layer,
> but it won't sit there any longer than it takes for it to go out the wire.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
