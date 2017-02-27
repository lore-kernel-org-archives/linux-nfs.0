Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44334 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751360AbdB0OUd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 27 Feb 2017 09:20:33 -0500
Date: Mon, 27 Feb 2017 09:20:31 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Tom Talpey <tom@talpey.com>, trond.myklebust@primarydata.com,
        schumaker.anna@gmail.com, linux-nfs@vger.kernel.org,
        chuck.lever@oracle.com, jgunthorpe@obsidianresearch.com
Subject: Re: [PATCH v2 0/4] nfs/nfsd/sunrpc: enforce NFSv4 transport
 requirements
Message-ID: <20170227142031.GA2142@fieldses.org>
References: <20170223170337.10686-1-jlayton@redhat.com>
 <20170224182525.10390-1-jlayton@redhat.com>
 <20170224212516.GH26378@fieldses.org>
 <1487972064.3314.8.camel@redhat.com>
 <20170224214442.GI26378@fieldses.org>
 <1488196763.2876.1.camel@redhat.com>
 <2c8602da-5e1b-a7d1-b03b-2a06442450f9@talpey.com>
 <1488200155.2876.3.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1488200155.2876.3.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 27, 2017 at 07:55:55AM -0500, Jeff Layton wrote:
> On Mon, 2017-02-27 at 07:08 -0500, Tom Talpey wrote:
> > On 2/27/2017 6:59 AM, Jeff Layton wrote:
> > > What we'd need to make that happen, I think is a [global] stanza in
> > > nfs.conf with a single 'nfsd_v3' boolean that defaults to off. If
> > 
> > Don't forget v2! And maybe even v4.0 if you're encouraging non-legacy
> > operation. RFC3530 was published 14 years ago, btw. RFC1813 in 1995,
> > and RFC1094 in 1989.

Looking just at the RHEL history.... I think we enabled experimental v4
in 2005 in RHEL4, but regretted that.  It wasn't a default until RHEL6
in 2010.  Other OS's were different, but in general I think
implementation lagged specification by a lot.  Ditto to some degree for
4.1.

> I think v2 already defaults to off these days? But yeah, I could see us
> adding a similar boolean for v2. Maybe we don't need a new switch at
> all, and just need to have everything look at the [nfsd] vers2= and
> vers3= config file options?
> 
> I think wiring nfsd and mountd up properly for this would be fairly easy
> here. statd is a little tougher since we don't want to run it or sm-
> notify at all if v2/3 are disabled. I wonder if there is any way we can
> make systemd look at this config file and decide whether to start statd
> based on whether either of those options is set?

Neil might have ideas--see https://lwn.net/Articles/701549/.

--b.

> I'd have no issue with eventually defaulting with v4.0 disabled as well,
> but there are a fair number of clients in the field that don't support
> v4.1 (or don't support it well). I think we'd need to wait and see how
> much grief we get about disabling v3 by default before we go there. 
