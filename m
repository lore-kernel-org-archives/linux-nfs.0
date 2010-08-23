Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:21633 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752737Ab0HWKKe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Aug 2010 06:10:34 -0400
Message-ID: <4C724914.2050206@panasas.com>
Date: Mon, 23 Aug 2010 13:10:28 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
CC: Benny Halevy <bhalevy@panasas.com>,
        "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH version2] nfsd41: Fix a crash when a callback is retried
References: <4C28DCE0.7050201@panasas.com> <4C29DA23.90200@panasas.com> <20100805142226.GA27141@fieldses.org>
In-Reply-To: <20100805142226.GA27141@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/05/2010 05:22 PM, J. Bruce Fields wrote:
> Thanks, applied.  There may be a delay before it shows up in my
> for-2.6.36 queue, while I sort out a few other bugs.
> 
> (We still have problems here: getting a new slot isn't always the
> correct thing to do, depending on the error.  But this seems an
> improvement....).
> 

We do free the slot unconditionally, (hence the crash) so we better
grab a new one.

Please store in the corner of your mind those cases you think should
not free the slot, I promise to put it on my todo, and come back to it.

We will then have to switch on these case that don't free the slot and
bail out early. At this point of the code, it will remain the same.

But you are right, I have not thought about these cases.

> --b.

Thanks
Boaz
