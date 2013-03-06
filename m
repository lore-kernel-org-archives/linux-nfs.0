Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f174.google.com ([209.85.128.174]:45519 "EHLO
	mail-ve0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754580Ab3CFVbK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Mar 2013 16:31:10 -0500
MIME-Version: 1.0
In-Reply-To: <20130306212452.GO1227@htj.dyndns.org>
References: <20130305082308.6607d4db@tlielax.poochiereds.net>
	<20130305174648.GF12795@htj.dyndns.org>
	<20130305174954.GG12795@htj.dyndns.org>
	<20130305140312.243cb094@tlielax.poochiereds.net>
	<20130305190923.GI12795@htj.dyndns.org>
	<20130305183941.19ff39ce@tlielax.poochiereds.net>
	<20130305234700.GE1227@htj.dyndns.org>
	<20130306181608.GA18687@redhat.com>
	<20130306185304.GM1227@htj.dyndns.org>
	<CA+55aFwDogteVd=vwGHXDSASnga-nZZnKaQz9aO1yBU2CPKSbA@mail.gmail.com>
	<20130306212452.GO1227@htj.dyndns.org>
Date: Wed, 6 Mar 2013 13:31:10 -0800
Message-ID: <CA+55aFy49AWptMcvEzJxg95ikf-dC+-vcCPq-cnaCCwje3tyoQ@mail.gmail.com>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
From: Linus Torvalds <torvalds@linux-foundation.org>
To: Tejun Heo <tj@kernel.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Jeff Layton <jlayton@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Mandeep Singh Baines <msb@chromium.org>,
        Ming Lei <ming.lei@canonical.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 6, 2013 at 1:24 PM, Tejun Heo <tj@kernel.org> wrote:
>
> With syscall paths out of the way, the surface is reduced a lot.

So the issue is syscalls that don't react to signals, and that can
potentially wait a long time.

Like NFS with a network hickup. Which is not at all unlikely. Think
wireless network, somebody trying to get on a network share, things
not working, and closing the damn lid because you give up.

So I do agree that we probably have *too* many of the stupid "let's
check if we can freeze", and I suspect that the NFS code should get
rid of the "freezable_schedule()" that is causing this warning
(because I also agree that you should *not* freeze while holding
locks, because it really can cause deadlocks), but I do suspect that
network filesystems do need to have a few places where they check for
freezing on their own... Exactly because freezing isn't *quite* like a
signal.

                 Linus
