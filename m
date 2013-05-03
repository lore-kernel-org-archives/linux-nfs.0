Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f174.google.com ([209.85.210.174]:47029 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933408Ab3ECQvm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 May 2013 12:51:42 -0400
Received: by mail-ia0-f174.google.com with SMTP id e36so1534465iag.33
        for <linux-nfs@vger.kernel.org>; Fri, 03 May 2013 09:51:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <16805.1367508760@mas.franz.com>
References: <16805.1367508760@mas.franz.com>
Date: Fri, 3 May 2013 09:51:42 -0700
Message-ID: <CABgxfbEuf-YfJT+7PTnXJvtetjaUCVez2EAoK1Q6azYN4Oib=g@mail.gmail.com>
Subject: Re: Unexpected NFS client cache drops
From: Wendy Cheng <s.wendy.cheng@gmail.com>
To: Ahmon Dancy <dancy@franz.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 2, 2013 at 8:32 AM, Ahmon Dancy <dancy@franz.com> wrote:
> Hello Linux NFS folks.  I need help figuring out why the kernel is
> sometimes discarding large portions of the page cache for a file that
> I'm manipulating via NFS.

It is quite normal for kernel to flush out page cache and there are
tunables to control the intervals and/or percentage. For example, a
quick googling shows results such as:
http://www.westnet.com/~gsmith/content/linux-pdflush.htm  .. Did you
try that out yet ?

Different filesystems have different policies for flushing as well -
this applies to NFS client and local filesystems. NFS client kmod
might clean its house more frequently due to:

1. It has more memory pressure (vs. local filesystem that does not
require socket buffers), particularly you run this on top of IB
interconnect that uses DMA extensively. Did you use IPOIB datagram or
IPOIB cm ?
2. NFS default with sync export - so the client side pages may have
zero reference count (read as "un-used") after the contents reach the
server. At that point, kernel is free to grab them

>
> Attached is the source for a test program which models the behavior of
> a larger program.  The program works as follows:
>

A test program is always a great way to kickoff the discussion. If you
don't get further comment here, you might want to open a Fedora
bugzilla to see whether anyone has cycles to run it and analyse the
result. I suspect there are more tunable can be done on the NUMA side.

I assume the hardware used by the xfs runs were identical to the NFS
client machine.

-- Wendy
