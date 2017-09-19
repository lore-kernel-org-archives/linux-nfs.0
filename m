Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50954 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750733AbdISRYx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Sep 2017 13:24:53 -0400
Date: Tue, 19 Sep 2017 13:24:52 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Daniel P. Berrange" <berrange@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
Message-ID: <20170919172452.GB29104@fieldses.org>
References: <20170915133145.GA23557@fieldses.org>
 <DE7FAAE5-26F5-4B11-A83D-F74C9B7D81FB@oracle.com>
 <20170915164223.GE23557@fieldses.org>
 <A1844833-18E1-4F03-BB20-A06A6FE4AB62@oracle.com>
 <20170918180927.GD12759@stefanha-x1.localdomain>
 <20170919093140.GF9536@redhat.com>
 <67608054-B771-44F4-8B2F-5F7FDC506CDD@oracle.com>
 <20170919151051.GS9536@redhat.com>
 <3534278B-FC7B-4AA5-AF86-92AA19BFD1DC@oracle.com>
 <20170919164427.GV9536@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170919164427.GV9536@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 19, 2017 at 05:44:27PM +0100, Daniel P. Berrange wrote:
> On Tue, Sep 19, 2017 at 11:48:10AM -0400, Chuck Lever wrote:
> > 
> > > On Sep 19, 2017, at 11:10 AM, Daniel P. Berrange <berrange@redhat.com> wrote:
> > > VSOCK requires no guest configuration, it won't be broken accidentally
> > > by NetworkManager (or equivalent), it won't be mistakenly blocked by
> > > guest admin/OS adding "deny all" default firewall policy. Similar
> > > applies on the host side, and since there's separation from IP networking,
> > > there is no possibility of the guest ever getting a channel out to the
> > > LAN, even if the host is mis-configurated.
> > 
> > We don't seem to have configuration fragility problems with other
> > deployments that scale horizontally.
> > 
> > IMO you should focus on making IP reliable rather than trying to
> > move familiar IP-based services to other network fabrics.
> 
> I don't see that ever happening, except in a scenario where a single
> org is in tight control of the whole stack (host & guest), which is
> not the case for cloud in general - only some on-site clouds.

Can you elaborate?

I think we're having trouble understanding why you can't just say "don't
do that" to someone whose guest configuration is interfering with the
network interface they need for NFS.

--b.
