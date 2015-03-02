Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:56093 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752714AbbCBBGi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 1 Mar 2015 20:06:38 -0500
Date: Sun, 1 Mar 2015 20:06:36 -0500
From: Bruce James Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux Network Devel Mailing List <netdev@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Weird TCP hang when doing loopback NFS (wireshark traces
 attached)
Message-ID: <20150302010636.GA8033@fieldses.org>
References: <1425237291.24845.13.camel@primarydata.com>
 <CAHQdGtSTJoKJZ8y72oLWTv30AZxVsRWAU0pTjZJy18jQ7Dhadw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtSTJoKJZ8y72oLWTv30AZxVsRWAU0pTjZJy18jQ7Dhadw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Mar 01, 2015 at 07:52:28PM -0500, Trond Myklebust wrote:
> Hi Bruce,
> 
> On Sun, Mar 1, 2015 at 2:14 PM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
> > Hi,
> >
> > When doing testing of NFSv3 loopback mounts (client and server are on
> > the same IP address), I'm seeing a very reproducible hang in which the
> > client stops receiving data from the server. The TCP connection is still
> > marked as established, and the server appears to continue to receive and
> > send data, however the client does not.
> >
> > So far, I've reproduced on both v4.0-rc1, and the Fedora v3.18.7 kernel.
> >
> > The reproducer is simply to loopback mount using NFSv3, and then run the
> > 'fsx' filesystem exerciser. I'm usually able to trigger the hang with
> > "fsx -N 100000 foobar".
> >
> > I've attached a couple of wireshark trace of a few frames just before
> > and during the hang in case it jogs any memories.
> 
> This bug appears to go away when I disable the splice()-based reads by
> clearing the RQ_SPLICE_OK flag.
> 
> I noticed that it always involved a combination of a READ and a
> truncating SETATTR call. Are you sure that it is safe to share
> pagecache pages directly with sendpage() in this way? As far as I can
> tell, there is no locking to prevent them from being modified while in
> the TCP send queue.

This is the stable-pages problem that we've had forever, isn't it?  Or
is this a different problem?

--b.
