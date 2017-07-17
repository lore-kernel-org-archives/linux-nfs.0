Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42564 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751325AbdGQRbU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 17 Jul 2017 13:31:20 -0400
Date: Mon, 17 Jul 2017 13:31:19 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "eguan@redhat.com" <eguan@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        hch <hch@lst.de>
Subject: Re: [4.13-rc1 regression] fstests generic/013 crashed nfsd on ppc64
 host
Message-ID: <20170717173119.GB9334@fieldses.org>
References: <20170717120809.GQ2478@eguan.usersys.redhat.com>
 <1500307208.4036.5.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1500307208.4036.5.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 17, 2017 at 04:00:10PM +0000, Trond Myklebust wrote:
> Please see the patch that I posted yesterday in response to Dave Jones'
> report of the same issue.
> 
> Bruce, do you want me to resend?

I've got it, thanks!

(Had to grep through the code to figure out why it doesn't change the
on-the-wire version number.  OK, I see, that's in rpc_version->number,
which is unchanged.)

--b.
