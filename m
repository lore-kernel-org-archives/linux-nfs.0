Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58808 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751163AbdE3RDO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 30 May 2017 13:03:14 -0400
Date: Tue, 30 May 2017 20:03:12 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
To: "bfields@fieldses.org" <bfields@fieldses.org>
Cc: hch <hch@lst.de>, Trond Myklebust <trondmy@primarydata.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        virtualization@lists.linux-foundation.org
Subject: Re: remove function pointer casts and constify function tables
Message-ID: <20170530200109-mutt-send-email-mst@kernel.org>
References: <1494620040.19467.1.camel@primarydata.com>
 <20170513072557.GA14602@lst.de>
 <1494691819.31377.1.camel@primarydata.com>
 <20170515152134.GC24547@fieldses.org>
 <20170515154450.GA18630@lst.de>
 <20170523081159.GA19216@lst.de>
 <20170523122334.GA4298@fieldses.org>
 <20170526150839.GA4593@fieldses.org>
 <20170526150956.GB4593@fieldses.org>
 <20170526193133.GA9874@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170526193133.GA9874@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 26, 2017 at 03:31:33PM -0400, bfields@fieldses.org wrote:
> Looks like the culprit is very likely d85b758f72b0 "virtio_net: fix
> support for small rings".
> 
> After that patch, my NFS server VM stops responding to packets after a
> few minutes of testing.  Before that patch, my server keeps working.
> 
> --b.


So I think I know what caused this: looks like some hypervisors
aren't prepared to deal with a situation where packet size
becomes very small.

But which hypervisors exactly? I'd like to know in order to detect these
and decide whether I blacklist bad ones or whitelist known-good ones.

Thanks!

-- 
MST
