Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f180.google.com ([209.85.192.180]:44272 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753472AbaIOJGB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Sep 2014 05:06:01 -0400
Received: by mail-pd0-f180.google.com with SMTP id ft15so5713838pdb.11
        for <linux-nfs@vger.kernel.org>; Mon, 15 Sep 2014 02:06:00 -0700 (PDT)
Message-ID: <5416ABF3.3040403@plexistor.com>
Date: Mon, 15 Sep 2014 12:05:55 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@lst.de>, Benny Halevy <bhalevy@primarydata.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: layoutcommit space reservation for the objlayout driver
References: <20140914164655.GB13467@lst.de>
In-Reply-To: <20140914164655.GB13467@lst.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/14/2014 07:46 PM, Christoph Hellwig wrote:
> Currently the NFS client does not reserved any space for the layoutupdate
> field when encoding a layoutcommit.  For the file layout driver which doesn't
> have a layoutupdate that's obviously fine, and for the block layoutdriver
> I just fixed the issue in my series by allowing to split in a set of
> preallocated pages.  The objlayout driver still needs this fixed, either
> by convincing Trond to increase the reservatation for the few objlayout
> fields, or by splicing in the pages like the block layout driver does.
> 
> Can someone with an objlayout setup take care of this?
> 

I do not understand. This used to work just fine. Please point me to
the patch that broke it?
(And since when are we allowed to brake old code?)

It will take me a bit of time to get up to speed. Do you want to attempt
a patch and I'll test it?

Thanks
Boaz

