Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f52.google.com ([74.125.82.52]:41331 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932421AbaHZJGu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Aug 2014 05:06:50 -0400
Received: by mail-wg0-f52.google.com with SMTP id a1so13972319wgh.11
        for <linux-nfs@vger.kernel.org>; Tue, 26 Aug 2014 02:06:49 -0700 (PDT)
Message-ID: <53FC4E26.8000605@gmail.com>
Date: Tue, 26 Aug 2014 12:06:46 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@lst.de>, Anna Schumaker <Anna.Schumaker@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 16/19] pnfs/blocklayout: rewrite extent tracking
References: <1408637375-11343-1-git-send-email-hch@lst.de> <1408637375-11343-17-git-send-email-hch@lst.de> <53FB49D9.1060803@Netapp.com> <20140825144340.GA16701@lst.de>
In-Reply-To: <20140825144340.GA16701@lst.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/25/2014 05:43 PM, Christoph Hellwig wrote:
> On Mon, Aug 25, 2014 at 10:36:09AM -0400, Anna Schumaker wrote:
>> Whoa, I like the amount of code you manage to remove in this patch!  However, there is a lot going on here.  Any way this patch could be split into incremental changes?  (it's okay to say "no"!)
> 
> The answer really is no - it's a wholesale replacement of three tracking
> structures with an integrated one that is managed very differently.  The only
> thing I had split out ealier where various trivial bug fixes like sector
> truncations in code that gets ripped out entirely later, so I decided to
> fold those again, which didn't increase the patch size by more than 10 lines.
> 

Right, same here. Anna it is best to just go read the code and don't dare
look at the patch itself. The patch will just complicate what is more
simple at the code level.

I have seen this patch and it is on my todo to review the new code
wholesale after this patch, to learn the nice structures Christoph
has introduced here.

Thanks
Boaz

