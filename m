Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f170.google.com ([209.85.220.170]:58452 "EHLO
	mail-vc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752009AbaIIVBj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2014 17:01:39 -0400
Received: by mail-vc0-f170.google.com with SMTP id hy4so2991477vcb.15
        for <linux-nfs@vger.kernel.org>; Tue, 09 Sep 2014 14:01:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <540F448D.4020600@RedHat.com>
References: <CA+Tkd6URVCziomwWMFYtxmQyybpC7=r_BTjnwVuduDaOa4cuvg@mail.gmail.com>
 <20140903070048.56201d1d@tlielax.poochiereds.net> <70D58138-CB00-433C-8BF8-01584E6460F0@oracle.com>
 <CA+Tkd6WV9K4oZPVGkqL_y6OcD9Pmj6x0roo9n839QD8RXDsCwA@mail.gmail.com>
 <CA+Tkd6WYkkVbY2YsmRNHB4+9AFg5UjC1xoycLTZQOYrtFCT_2w@mail.gmail.com>
 <CAHQdGtRpD03KHJyu1MtxA=21pu4z_YAG4XA-8Bu+t4xeUefaNQ@mail.gmail.com>
 <CA+Tkd6WBuMkCmsjUpjrAR38Ri6QK_B4BhgNr0gzHBTG1ytjO6Q@mail.gmail.com>
 <CA+Tkd6UjfJmjG0WE1F2bsB068rXkEUHhOq6S+F5e=OVA_wxeMw@mail.gmail.com> <540F448D.4020600@RedHat.com>
From: Chris Perl <chris.perl@gmail.com>
Date: Tue, 9 Sep 2014 17:01:18 -0400
Message-ID: <CA+Tkd6WHP_a0VEhJwTZELs9pNhp1vdVayuuNywhLt8F-0G2+kQ@mail.gmail.com>
Subject: Re: nfs-utils - TCP ephemeral port exhaustion results in mount failures
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jeff.layton@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> I have not seen anything....

I didn't send the patches in reply to this thread, so perhaps that
confused matters.  Trond already commented on the kernel one.

The two patches are referenced below via gmane.org (not sure if there
is a better way to direct you to them):

[1] http://thread.gmane.org/gmane.linux.nfs/66173 (sunrpc module patch)
[2] http://thread.gmane.org/gmane.linux.nfs/66175 (mount.nfs patch)
