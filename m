Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f177.google.com ([209.85.216.177]:34362 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752922Ab3CGQAz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Mar 2013 11:00:55 -0500
Date: Thu, 7 Mar 2013 08:00:49 -0800
From: Tejun Heo <tj@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jeff Layton <jlayton@redhat.com>, Oleg Nesterov <oleg@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Mandeep Singh Baines <msb@chromium.org>,
        Ming Lei <ming.lei@canonical.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
Message-ID: <20130307160049.GC29601@htj.dyndns.org>
References: <20130305183941.19ff39ce@tlielax.poochiereds.net>
 <20130305234700.GE1227@htj.dyndns.org>
 <20130306181608.GA18687@redhat.com>
 <20130306185304.GM1227@htj.dyndns.org>
 <CA+55aFwDogteVd=vwGHXDSASnga-nZZnKaQz9aO1yBU2CPKSbA@mail.gmail.com>
 <20130306212452.GO1227@htj.dyndns.org>
 <CA+55aFy49AWptMcvEzJxg95ikf-dC+-vcCPq-cnaCCwje3tyoQ@mail.gmail.com>
 <20130306213636.GP1227@htj.dyndns.org>
 <20130307064140.71c0936b@tlielax.poochiereds.net>
 <CA+55aFxe1_x8wvVYciiX8tuee+VsmXGKqEbONQdFM4s4W2iuPg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+55aFxe1_x8wvVYciiX8tuee+VsmXGKqEbONQdFM4s4W2iuPg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Linus.

On Thu, Mar 07, 2013 at 07:55:39AM -0800, Linus Torvalds wrote:
> In other words, that suggestion not only introduces new problems (a),
> it's fundamentally broken anyway (b) *AND* it doesn't even solve
> anything, it just moves it around.

I don't think it's gonna solve the problems we're talking about but
the "moving around" part could be useful nonetheless - e.g. we don't
want to shut down network before nfs while suspending.

Thanks.

-- 
tejun
