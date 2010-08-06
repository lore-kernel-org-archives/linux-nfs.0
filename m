Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from puma-mxisp.mxtelecom.com ([83.166.71.4]:57773 "EHLO
	puma.mxtelecom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752066Ab0HFQ3d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Aug 2010 12:29:33 -0400
Message-ID: <4C5C3869.1040900@mxtelecom.com>
Date: Fri, 06 Aug 2010 17:29:29 +0100
From: Matthew Hodgson <matthew@mxtelecom.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org
Subject: Re: Tuning NFS client write pagecache
References: <4C5BFE47.8020905@mxtelecom.com> <20100806132620.GA2921@merit.edu>
In-Reply-To: <20100806132620.GA2921@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

Jim Rees wrote:
> Matthew Hodgson wrote:
> 
>   Is there any way to tune the linux NFSv3 client to prefer to write
>   data straight to an async-mounted server, rather than having large
>   writes to a file stack up in the local pagecache before being synced
>   on close()?
> 
> It's been a while since I've done this, but I think you can tune this with
> vm.dirty_writeback_centisecs and vm.dirty_background_ratio sysctls.  The
> data will still go through the page cache but you can reduce the amount
> that
> stacks up.

Yup, that does the trick - I'd tried this earlier, but hadn't gone far 
enough - seemingly I need to drop vm.dirty_writeback_centisecs down to 1 
(and vm.dirty_background_ratio to 1) for the back-pressure to propagate 
correctly for this use case.  Thanks for the pointer!

In other news, whilst saturating the ~10Mb/s pipe during the big write 
to the server, I'm seeing huge delays of >10 seconds on trying to do 
trivial operations such as ls'ing small directories.  Is this normal, or 
is there some kind of tunable scheduling on the client to avoid a single 
big transfer wedging the machine?

thanks,

Matthew

-- 
Matthew Hodgson
Development Program Manager
OpenMarket | www.openmarket.com/europe
matthew.hodgson@openmarket.com
