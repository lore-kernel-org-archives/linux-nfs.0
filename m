Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:33820 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753371Ab2BHHnv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 02:43:51 -0500
Message-ID: <1328687026.8981.25.camel@serendib>
Subject: Re: NFS Mount Option 'nofsc'
From: Harshula <harshula@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Derek McEachern <derekm@ti.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Wed, 08 Feb 2012 18:43:46 +1100
In-Reply-To: <1328676860.2954.9.camel@lade.trondhjem.org>
References: <4F31E1CA.8060105@ti.com>
	 <1328676860.2954.9.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On Wed, 2012-02-08 at 04:55 +0000, Myklebust, Trond wrote:

> Applications that need to use uncached i/o are required to use the
> O_DIRECT open() mode instead, since pretty much all of them need to be
> rewritten to deal with the subtleties involved anyway.

Could you please expand on the subtleties involved that require an
application to be rewritten if forcedirectio mount option was available?

A scenario where forcedirectio would be useful is when an application
reads nearly a TB of data from local disks, processes that data and then
dumps it to an NFS mount. All that happens while other processes are
reading/writing to the local disks. The application does not have an
O_DIRECT option nor is the source code available.

With paged I/O the problem we see is that the NFS client system reaches
dirty_bytes/dirty_ratio threshold and then blocks/forces all the
processes to flush dirty pages. This effectively 'locks' up the NFS
client system while the NFS dirty pages are pushed slowly over the wire
to the NFS server. Some of the processes that have nothing to do with
writing to the NFS mount are badly impacted. A forcedirectio mount
option would be very helpful in this scenario. Do you have any advice on
alleviating such problems on the NFS client by only using existing
tunables?

Thanks,
#

