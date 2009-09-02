Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:38496 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753296AbZIBTKq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2009 15:10:46 -0400
Received: by bwz19 with SMTP id 19so961318bwz.37
        for <linux-nfs@vger.kernel.org>; Wed, 02 Sep 2009 12:10:47 -0700 (PDT)
In-Reply-To: <1f808b4a0909021135m49c2e60o6b305babcaed295c@mail.gmail.com>
References: <20090902180841.GF946@proxime.net>
	 <e7ca40f70909021119r2f49724dj705e334cf1ae9b3a@mail.gmail.com>
	 <1f808b4a0909021135m49c2e60o6b305babcaed295c@mail.gmail.com>
Date: Wed, 2 Sep 2009 15:10:47 -0400
Message-ID: <e7ca40f70909021210p646e2635l267ac6def345b4c7@mail.gmail.com>
Subject: Re: NFS for millions of files
From: Aaron Wiebe <epiphani@gmail.com>
To: Peter Chacko <peterchacko35@gmail.com>
Cc: Jason Legate <linux-nfs@proxime.net>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Sep 2, 2009 at 2:35 PM, Peter Chacko<peterchacko35@gmail.com> wrote:
> Is this NFSv4 ?  rsize and wsize > MTU size will cause fragmentation
> and performance issues...Try making it around 4k .....You used  1<<15
> fir your example. if you don't do writes....then this shouldn't
> matter...and of course NFS is  Nfs is not For Scalability.. You cannot
> get the same performance on NFS as you would get for localFS...May be
> you can try 10g....still there is TCP/UDP/IP stack overhead.....

Fragmentation won't hurt you that much, and it doesn't even apply to
opens, since those operations are significantly smaller.  The
performance gains higher in the stack from a larger rsize/wsize
generally outweigh the savings in frame size optimization.  Of course,
jumbo frames are always a good idea, but again, doesn't help here.

-Aaron
