Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:56722 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753835AbbCBT6D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Mar 2015 14:58:03 -0500
Date: Mon, 2 Mar 2015 14:58:01 -0500
From: Bruce James Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux Network Devel Mailing List <netdev@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Weird TCP hang when doing loopback NFS (wireshark traces
 attached)
Message-ID: <20150302195801.GF8033@fieldses.org>
References: <1425237291.24845.13.camel@primarydata.com>
 <CAHQdGtSTJoKJZ8y72oLWTv30AZxVsRWAU0pTjZJy18jQ7Dhadw@mail.gmail.com>
 <20150302010636.GA8033@fieldses.org>
 <CAHQdGtQcrF4fs0Tb3jTQ6iGXzOhhjRNAezrq_eOfzo_cFxh1Xw@mail.gmail.com>
 <CAHQdGtQnbPWYhdvwTGJKUD4mt8x_rmQjCH3AO4X17Y4RBSpUQQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtQnbPWYhdvwTGJKUD4mt8x_rmQjCH3AO4X17Y4RBSpUQQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Mar 01, 2015 at 11:31:31PM -0500, Trond Myklebust wrote:
> On Sun, Mar 1, 2015 at 8:20 PM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
> > On Sun, Mar 1, 2015 at 8:06 PM, Bruce James Fields <bfields@fieldses.org> wrote:
> >> On Sun, Mar 01, 2015 at 07:52:28PM -0500, Trond Myklebust wrote:
> >>> Hi Bruce,
> >>>
> >>> On Sun, Mar 1, 2015 at 2:14 PM, Trond Myklebust
> >>> <trond.myklebust@primarydata.com> wrote:
> >>> > Hi,
> >>> >
> >>> > When doing testing of NFSv3 loopback mounts (client and server are on
> >>> > the same IP address), I'm seeing a very reproducible hang in which the
> >>> > client stops receiving data from the server. The TCP connection is still
> >>> > marked as established, and the server appears to continue to receive and
> >>> > send data, however the client does not.
> >>> >
> >>> > So far, I've reproduced on both v4.0-rc1, and the Fedora v3.18.7 kernel.
> >>> >
> >>> > The reproducer is simply to loopback mount using NFSv3, and then run the
> >>> > 'fsx' filesystem exerciser. I'm usually able to trigger the hang with
> >>> > "fsx -N 100000 foobar".
> >>> >
> >>> > I've attached a couple of wireshark trace of a few frames just before
> >>> > and during the hang in case it jogs any memories.
> >>>
> >>> This bug appears to go away when I disable the splice()-based reads by
> >>> clearing the RQ_SPLICE_OK flag.
> >>>
> >>> I noticed that it always involved a combination of a READ and a
> >>> truncating SETATTR call. Are you sure that it is safe to share
> >>> pagecache pages directly with sendpage() in this way? As far as I can
> >>> tell, there is no locking to prevent them from being modified while in
> >>> the TCP send queue.
> >>
> >> This is the stable-pages problem that we've had forever, isn't it?  Or
> >> is this a different problem?
> >
> > It is causing the TCP socket to hang, so it goes beyond the usual
> > stable pages issue.
> >
> 
> Confirming that clearing RQ_SPLICE_OK fixes the issue on all kernel
> that I've tested so far.

Well, if the problem is a race with truncate then I guess it may have
something to do with sending pages that are no longer part of the page
cache?

I'd think that the get_page() in nfsd_splice_actor would prevent the
page being put to any other use until the network layer was done with
it, so that at worst the client would see garbage.  But I don't begin to
understand how truncation actually works....

The zero-copy v3 code has been there since 2002, if I'm reading the
history right, so if it's really a fundamental problem with the approach
then I wonder how it's survived so long.

I haven't tried to reproduce yet.

--b.
