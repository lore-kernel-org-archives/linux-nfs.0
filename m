Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43090 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752825AbeDQPlI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Apr 2018 11:41:08 -0400
Date: Tue, 17 Apr 2018 11:41:06 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v8 0/9] NFSD support for async COPY
Message-ID: <20180417154106.GG10291@parsley.fieldses.org>
References: <20180413170158.17589-1-kolga@netapp.com>
 <20180414072202.GA6514@infradead.org>
 <20180416214522.GC2634@parsley.fieldses.org>
 <20180417065203.GA15145@infradead.org>
 <20180417150002.GF10291@parsley.fieldses.org>
 <23541B87-1142-4B59-BD57-F572FB8C1C4A@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <23541B87-1142-4B59-BD57-F572FB8C1C4A@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 17, 2018 at 11:17:03AM -0400, Olga Kornievskaia wrote:
> 
> 
> > On Apr 17, 2018, at 11:00 AM, J. Bruce Fields <bfields@redhat.com>
> > wrote:
> > 
> > On Mon, Apr 16, 2018 at 11:52:03PM -0700, Christoph Hellwig wrote:
> >> Also even if we have a good reason to add it I absolutely want a
> >> config option for the feature - it is a lot code adding potential
> >> attack vectors, so we should not just enabled it by default.
> > 
> > By the way, am I forgetting some mitigation or can a client provide
> > any address it wants as the source server to copy from?
> > 
> > That opens up the server to a lot of the same risks you'd see from
> > unprivileged NFS mounts--a malicious client could copy from a server
> > under it's control that's modified to exploit bugs in the server's
> > NFS client code.
> 
> There is nothing in the specification that can protects from a
> malicious user to initiate a copy. There is GSSv3 that were added to
> prevent unprivileged server from accessing information from the source
> server without the user’s knowledge. I don’t see how copy offload is
> the same as unprivileged NFS mount. What copy offload feature offers
> is ability to READ a very specific file. 

I can't remember how much more protocol you need besides READ....  If
you support 4.1+ as the copy protocol then you probably also need to do
EXCHANGE_ID and CREATE_SESSION?  Fair enough, I agree that you're not
exposing as much of the client code as an unprivileged mount would, but
it's still a lot of opportunities for something to go wrong.

> We do have in the pipe line GSSv3 implementation as well as the COPY
> piece that uses it. It was implemented by Andy and inherited by Anna.
> However, before we could submit that we need the copy offload to go
> in.

A malicious client can give the server credentials that a server under
its control will accept.  GSSv3 lets the source server authenticate the
read requests, but I don't think it helps here.

--b.
