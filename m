Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:39920 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751105AbdJMUTX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 13 Oct 2017 16:19:23 -0400
Date: Fri, 13 Oct 2017 16:19:23 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Thomas Haynes <loghyr@primarydata.com>,
        "loghyr@excfb.com" <loghyr@excfb.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>
Subject: Re: pynfs replay cache test SEQ9f
Message-ID: <20171013201923.GA16149@fieldses.org>
References: <E0161195-9F4A-4B36-A71D-6A924498C893@primarydata.com>
 <20171012194946.GC5233@fieldses.org>
 <6F78E570-F9B0-41A9-B224-3F2313AA8D4F@primarydata.com>
 <20171012214454.GA19598@fieldses.org>
 <20171012220051.GB29204@psyklo.internal.excfb.com>
 <20171013015223.GA21284@fieldses.org>
 <1507901666.4550.2.camel@primarydata.com>
 <20171013150021.GG5233@fieldses.org>
 <1507908409.9498.14.camel@primarydata.com>
 <20171013185015.GA15087@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171013185015.GA15087@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 13, 2017 at 02:50:15PM -0400, bfields@fieldses.org wrote:
> Those all involve uncached compounds with more than one op.  My reading
> of knfsd code is that it will return RETRY_UNCACHED_REP in this case,
> and I think (I might be misunderstanding) that the client will bump the
> slot seqid and retry in that case.  So I *think* you shouldn't be seeing
> that problem with knfsd?

So to bring it back to the original question, I'm still not sure it's
actually a problem if a server returns NFS_OK when cache_this is set
differently betwen two compound calls each containing just a single
SEQUENCE.

But, maybe it's worth at least warning about.

--b.
