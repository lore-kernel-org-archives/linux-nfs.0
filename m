Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:55563 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752082AbdBHVjb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Feb 2017 16:39:31 -0500
Date: Wed, 8 Feb 2017 13:39:14 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chucklever@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: NFS server regression in v4.10-rc7
Message-ID: <20170208213914.GA1863@infradead.org>
References: <1485246161-20874-1-git-send-email-hch@lst.de>
 <60D0607E-7D01-4F68-A447-071B7DEC6F23@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <60D0607E-7D01-4F68-A447-071B7DEC6F23@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 08, 2017 at 04:27:30PM -0500, Chuck Lever wrote:
> The test is run like this: "cd /mnt/server/git; make clean; make; make test"
> 
> Can anyone else reproduce this failure?

What local file system do you use on the server?
