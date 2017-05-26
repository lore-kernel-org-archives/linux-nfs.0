Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:39146 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752055AbdEZTbe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 26 May 2017 15:31:34 -0400
Date: Fri, 26 May 2017 15:31:33 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: hch <hch@lst.de>, Trond Myklebust <trondmy@primarydata.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        virtualization@lists.linux-foundation.org
Subject: Re: remove function pointer casts and constify function tables
Message-ID: <20170526193133.GA9874@fieldses.org>
References: <20170512161701.22468-1-hch@lst.de>
 <1494620040.19467.1.camel@primarydata.com>
 <20170513072557.GA14602@lst.de>
 <1494691819.31377.1.camel@primarydata.com>
 <20170515152134.GC24547@fieldses.org>
 <20170515154450.GA18630@lst.de>
 <20170523081159.GA19216@lst.de>
 <20170523122334.GA4298@fieldses.org>
 <20170526150839.GA4593@fieldses.org>
 <20170526150956.GB4593@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170526150956.GB4593@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks like the culprit is very likely d85b758f72b0 "virtio_net: fix
support for small rings".

After that patch, my NFS server VM stops responding to packets after a
few minutes of testing.  Before that patch, my server keeps working.

--b.
