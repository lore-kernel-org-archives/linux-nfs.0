Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:56117 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931AbaIEUDM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2014 16:03:12 -0400
Received: by mail-vc0-f174.google.com with SMTP id hy4so13020920vcb.33
        for <linux-nfs@vger.kernel.org>; Fri, 05 Sep 2014 13:03:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+Tkd6WYkkVbY2YsmRNHB4+9AFg5UjC1xoycLTZQOYrtFCT_2w@mail.gmail.com>
References: <CA+Tkd6URVCziomwWMFYtxmQyybpC7=r_BTjnwVuduDaOa4cuvg@mail.gmail.com>
	<20140903070048.56201d1d@tlielax.poochiereds.net>
	<70D58138-CB00-433C-8BF8-01584E6460F0@oracle.com>
	<CA+Tkd6WV9K4oZPVGkqL_y6OcD9Pmj6x0roo9n839QD8RXDsCwA@mail.gmail.com>
	<CA+Tkd6WYkkVbY2YsmRNHB4+9AFg5UjC1xoycLTZQOYrtFCT_2w@mail.gmail.com>
Date: Fri, 5 Sep 2014 16:03:11 -0400
Message-ID: <CAHQdGtRpD03KHJyu1MtxA=21pu4z_YAG4XA-8Bu+t4xeUefaNQ@mail.gmail.com>
Subject: Re: nfs-utils - TCP ephemeral port exhaustion results in mount failures
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chris Perl <chris.perl@gmail.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jeff.layton@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 5, 2014 at 3:40 PM, Chris Perl <chris.perl@gmail.com> wrote:
> I just submitted two patches, one for nfs-utils and one for linux-nfs.
>
> As I said in my previous email, the patch to nfs-utils was enough to
> get us farther along, but we failed inside mount(2) with EIO (with a
> decidedly more confusing error message).
>
> So, I've also submitted a patch for the rpc code in the kernel that
> also avoids bind when asking for a random ephemeral port.  I've tested
> the combination of these two patches with my system while in the
> situation I originally outlined.  I can continue to successfully mount
> NFS filesystems using both of these patches.
>
> I don't particularly love the kernel patch, as it makes `xs_bind' not
> actually bind in all circumstances, which seems confusing.  However, I
> thought trying to rework things in a larger way would cause more
> issues given that I'm not very familiar with this code.  If everyone
> hates it, I can try something else.

To whom did you submit these patches? I don't see anything in the
linux-nfs mailing list.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
