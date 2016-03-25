Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41249 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750818AbcCYBaP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Mar 2016 21:30:15 -0400
Date: Fri, 25 Mar 2016 02:28:57 +0100
From: Oleg Nesterov <oleg@redhat.com>
To: Ian Kent <raven@themaw.net>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Jeff Layton <jlayton@redhat.com>, Greg KH <gregkh@linuxfoundation.org>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, devel@openvz.org, bfields@fieldses.org,
        bharrosh@panasas.com
Subject: Re: call_usermodehelper in containers
Message-ID: <20160325012857.GA17892@redhat.com>
References: <20131111071825.62da01d1@tlielax.poochiereds.net> <20131112004703.GB15377@kroah.com> <20131112061201.04cf25ab@tlielax.poochiereds.net> <528226EC.4050701@parallels.com> <20131112083043.0ab78e67@tlielax.poochiereds.net> <5285FA0A.2080802@parallels.com> <871u2incyo.fsf@xmission.com> <20131118172844.GA10005@redhat.com> <1458805544.3099.16.camel@themaw.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1458805544.3099.16.camel@themaw.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Ian,

I can't really recall this old discussion, so I can be easily wrong...

On 03/24, Ian Kent wrote:
>
> On Mon, 2013-11-18 at 18:28 +0100, Oleg Nesterov wrote:
> >
> > IOW. Please the the "patch" below. It is obviously incomplete and
> > wrong,
> > and it can be more clear/clean. And probably we need another API. Just
> > to explain what I mean.

I hope you didn't miss this part ;)

In particular, we want to turn task_work_add(..., bool notify) into
task_work_add(..., how_to_notify mask) and this "mask" should allow
to force TIF_SIGPENDING.

> > With this patch call_usermodehelper(..., UMH_IN_MY_NS) should do exec
> > from the caller's namespace.
>
> Umm ... I don't think this can work.
>
> I don't think it can be assumed that the init process of a container
> will behave like an init process.
>
> If you try and do this with a Docker container that has /bin/bash as the
> init process signals never arrive and work doesn't start until some
> other signal arrives

only if it blocks/ignores SIGCHLD? But this doesn't matter, see above and
note the "until we have task_work_add_interruptibel()" in the pseudo-code
I showed.

> I probably don't understand what's actually going on, this is just my
> impression of what I'm seeing.

Or perhaps it is me who misunderstands your concerns.

Oleg.

