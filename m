Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53523 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751791Ab2KSVPW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Nov 2012 16:15:22 -0500
Date: Mon, 19 Nov 2012 16:15:18 -0500
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [RFC PATCH V2] mount: Added the -o v4.1 mount option
Message-ID: <20121119211518.GA10699@fieldses.org>
References: <1353339810-19126-1-git-send-email-steved@redhat.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9092EEE7A@SACEXCMBX04-PRD.hq.netapp.com>
 <50AA571E.4090509@RedHat.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9092EEFD7@SACEXCMBX04-PRD.hq.netapp.com>
 <50AA5AD4.5070808@RedHat.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9092EF0B3@SACEXCMBX04-PRD.hq.netapp.com>
 <8B557EF0-A1F7-4487-8887-0B08F6922784@oracle.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9092EF4AA@SACEXCMBX04-PRD.hq.netapp.com>
 <428AB13F-9EE3-4357-8C88-11F2DA45453C@oracle.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9092EF662@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9092EF662@SACEXCMBX04-PRD.hq.netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 19, 2012 at 07:04:10PM +0000, Myklebust, Trond wrote:
> On Mon, 2012-11-19 at 13:39 -0500, Chuck Lever wrote:
> > On Nov 19, 2012, at 1:29 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> > > As for minor version negotiation, RFC3530 already tells you how to do
> > > this: the client has to start with the highest version that it supports,
> > > and then walk that number down until the server stops replying with
> > > NFS4ERR_MINOR_VERS_MISMATCH.
> > > 
> > > Note that if you want to do this in userland before calling the mount
> > > syscall, then the spec does allow you to "ping" the NFSv4 server with an
> > > empty COMPOUND.
> > 
> > I see: not an NFSv4 NULL, but an NFSv4 COMPOUND that has no operations.  That carries a compound header, which would have the minor version number in it.
> 
> Right. Section 16.2.4 of RFC5661 would appear to allow the server to
> return the following errors in the case of an empty COMPOUND: NFS4_OK,
> NFS4ERR_DELAY, NFS4ERR_MINOR_VERS_MISMATCH and NFS4ERR_SERVERFAULT.
> 
> The other errors shouldn't apply at all to a zero-op compound
> (NFS4ERR_BADXDR, NFS4ERR_TOO_MANY_OPS, NFS4ERR_REP_TOO_BIG_TO_CACHE), or
> should only apply if you have a non-empty optional tag argument
> (NFS4ERR_BADCHAR, NFS4ERR_INVAL, NFS4ERR_REP_TOO_BIG,
> NFS4ERR_REQ_TOO_BIG).

And, I just wanted to check because I hadn't thought about this before:
the Linux server does appear to handle 0-length compounds correctly.
(And there's a 4.0 pynfs test, COMP1, which checks that a server will
accept a zero-length compound, so anyone that's run pynfs should have
noticed if there server doesn't.)

--b.
