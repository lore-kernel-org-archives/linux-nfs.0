Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50498 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751019AbdHXE7G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 24 Aug 2017 00:59:06 -0400
Subject: Re: Do we really need d_weak_revalidate???
To: NeilBrown <neilb@suse.com>,
        "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
        David Howells <dhowells@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>
Cc: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "mkoutny@suse.com" <mkoutny@suse.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
References: <87bmnmrai9.fsf@notabene.neil.brown.name>
 <1502430944.3822.1.camel@primarydata.com>
 <1502449309.4950.2.camel@redhat.com>
 <87zib3niqn.fsf@notabene.neil.brown.name>
 <1502705432.4978.1.camel@redhat.com>
 <877ey4nsep.fsf@notabene.neil.brown.name>
 <1502883253.4847.6.camel@redhat.com>
 <1e4665a6-30d6-c16a-760a-2892fb147760@redhat.com>
 <878tihmora.fsf@notabene.neil.brown.name>
 <2e289bba-677b-cc50-5fa3-2d24d1f6b858@redhat.com>
 <87h8x1l9qp.fsf@notabene.neil.brown.name>
 <733c15c2-ffbb-9a89-90ec-3ba1d574590e@redhat.com>
 <87r2w3jdn5.fsf@notabene.neil.brown.name>
 <42ba2fa5-d756-d70f-370c-c2fe1a61c5bf@redhat.com>
 <87inhdk3rq.fsf@notabene.neil.brown.name>
From: Ian Kent <ikent@redhat.com>
Message-ID: <40aa347f-43eb-faf7-d6b7-dce6897f8a85@redhat.com>
Date: Thu, 24 Aug 2017 12:58:55 +0800
MIME-Version: 1.0
In-Reply-To: <87inhdk3rq.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 24/08/17 12:07, NeilBrown wrote:
> 
> 
> The more precise details, that automount action for indirect automount
> points is not triggered when the 'browse' option is used, is probably
> not necessary.
> 
> Ian: if you agree with that text, and Michael doesn't provide alternate
> evidence, I'll submit a formal patch for the man page.... or should we
> just wait until the patch actually lands?

So far only David commented about using ENOENT rather than EREMOTE.

I prefer ENOENT for this case myself and he didn't object when I
explained why, David, any concerns?

Al has been silent so far so either he hasn't seen it or he's ok with
it, Al, any concerns?

And I guess if there are no concerns there's a good chance Andrew is
ok with it for the next merge window, Andrew?

If everyone agrees then we could go ahead immediately so there's a
better chance of getting it into released man pages closer to the
change being merged.

Ian
