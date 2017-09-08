Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50201 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756174AbdIHPPw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Sep 2017 11:15:52 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <40aa347f-43eb-faf7-d6b7-dce6897f8a85@redhat.com>
References: <40aa347f-43eb-faf7-d6b7-dce6897f8a85@redhat.com> <87bmnmrai9.fsf@notabene.neil.brown.name> <1502430944.3822.1.camel@primarydata.com> <1502449309.4950.2.camel@redhat.com> <87zib3niqn.fsf@notabene.neil.brown.name> <1502705432.4978.1.camel@redhat.com> <877ey4nsep.fsf@notabene.neil.brown.name> <1502883253.4847.6.camel@redhat.com> <1e4665a6-30d6-c16a-760a-2892fb147760@redhat.com> <878tihmora.fsf@notabene.neil.brown.name> <2e289bba-677b-cc50-5fa3-2d24d1f6b858@redhat.com> <87h8x1l9qp.fsf@notabene.neil.brown.name> <733c15c2-ffbb-9a89-90ec-3ba1d574590e@redhat.com> <87r2w3jdn5.fsf@notabene.neil.brown.name> <42ba2fa5-d756-d70f-370c-c2fe1a61c5bf@redhat.com> <87inhdk3rq.fsf@notabene.neil.brown.name>
To: Ian Kent <ikent@redhat.com>
Cc: dhowells@redhat.com, NeilBrown <neilb@suse.com>,
        "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>,
        Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "mkoutny@suse.com" <mkoutny@suse.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Subject: Re: Do we really need d_weak_revalidate???
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 08 Sep 2017 16:15:49 +0100
Message-ID: <32654.1504883749@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ian Kent <ikent@redhat.com> wrote:

> So far only David commented about using ENOENT rather than EREMOTE.
> 
> I prefer ENOENT for this case myself and he didn't object when I
> explained why, David, any concerns?

Not really - it just seems EREMOTE is a better fit since there is something
there, we're just not allowed to follow it.  This is different to a dangling
symlink IMO.

David
