Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f169.google.com ([209.85.220.169]:44829 "EHLO
	mail-vc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751684AbaIEWfG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2014 18:35:06 -0400
Received: by mail-vc0-f169.google.com with SMTP id hq11so13133891vcb.14
        for <linux-nfs@vger.kernel.org>; Fri, 05 Sep 2014 15:35:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <44C76FD6-5333-402B-9DA4-D38065AAA15F@primarydata.com>
References: <CA+Tkd6URVCziomwWMFYtxmQyybpC7=r_BTjnwVuduDaOa4cuvg@mail.gmail.com>
 <20140903070048.56201d1d@tlielax.poochiereds.net> <70D58138-CB00-433C-8BF8-01584E6460F0@oracle.com>
 <CA+Tkd6WV9K4oZPVGkqL_y6OcD9Pmj6x0roo9n839QD8RXDsCwA@mail.gmail.com>
 <CA+Tkd6WYkkVbY2YsmRNHB4+9AFg5UjC1xoycLTZQOYrtFCT_2w@mail.gmail.com>
 <CAHQdGtRpD03KHJyu1MtxA=21pu4z_YAG4XA-8Bu+t4xeUefaNQ@mail.gmail.com>
 <CA+Tkd6WBuMkCmsjUpjrAR38Ri6QK_B4BhgNr0gzHBTG1ytjO6Q@mail.gmail.com>
 <CA+Tkd6UjfJmjG0WE1F2bsB068rXkEUHhOq6S+F5e=OVA_wxeMw@mail.gmail.com> <44C76FD6-5333-402B-9DA4-D38065AAA15F@primarydata.com>
From: Chris Perl <chris.perl@gmail.com>
Date: Fri, 5 Sep 2014 18:34:44 -0400
Message-ID: <CA+Tkd6VhFr7txTTrVF_WrUsTCudr=BspZKN5j-WYVjv=VkkU+w@mail.gmail.com>
Subject: Re: nfs-utils - TCP ephemeral port exhaustion results in mount failures
To: Weston Andros Adamson <dros@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jeffrey Layton <jeff.layton@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Do these patches require one another?
>
> What happens if I have a patched nfs-utils, but not a patched kernel or the other way around?

They don't require each other per se.

If you have a patched kernel without a patched nfs-utils, then
attempts to mount when all ephemeral ports are already a part of at
least 1 TCP connection will fail with an EADDRINUSE from mount.nfs(8)
attempting to call bind(2).  It will never get around to calling
mount(2) and never enter the kernel RPC code.

If you have a patched nfs-utils without a patched kernel, its a little
unfortunate in that mount.nfs(8) will call mount(2), but that will
give an EIO when `xs_bind' tries to call `kernel_bind' which returns
EADDRINUSE.

I say unfortunate because in this scenario you get the less helpful
EIO back from mount(2) rather than the EADDRINUSE from bind(2),
meaning the end user sees "input/output error" rather than "address
already in use," where the latter is the real issue.
