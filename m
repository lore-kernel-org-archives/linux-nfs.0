Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:41016 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752477AbdFNUxU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jun 2017 16:53:20 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: Proposal for end-of-life for fedfs-utils development
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <56804FBE-34B2-47FB-96EF-013D4476D89A@oracle.com>
Date: Wed, 14 Jun 2017 16:53:07 -0400
Cc: "fedfs-utils;release announcements"
        <fedfs-utils-announce@oss.oracle.com>, autofs@vger.kernel.org,
        Chuck Lever via samba-technical
        <samba-technical@lists.samba.org>
Message-Id: <43E4D612-8CCD-4511-9E1D-265F4D459EE6@oracle.com>
References: <56804FBE-34B2-47FB-96EF-013D4476D89A@oracle.com>
To: fedfs-utils Developers <fedfs-utils-devel@oss.oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 2, 2017, at 11:01 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
> Upstream fedfs-utils has not been under active development for
> two years or more, and there is a scant user base. I'd like to
> propose making 0.10 the final major release of fedfs-utils.
> 
> The plan:
> 
> - Since 0.10 is in at least one major enterprise distribution,
> I will remain available to integrate security fixes and make
> new minor releases in the 0.10 line, as needed, for one to
> two more years.
> 
> - Retire and remove fedfs-utils from upstream mirror distros
> such as Fedora rawhide.
> 
> - Transfer utilities such as nfsref into nfs-utils, with
> support for FedFS junctions removed.
> 
> - Announcements of the change in status will be made on
> fedfs-utils-announce and on the wiki.linux-nfs.org site.
> 
> 
> 
> Comments welcome!

This was meant as a Request For Comments, but the cat is
out of bag now:

https://lwn.net/Articles/725411/rss

;-)

I haven't heard any objections to this proposal, so let's
go with it. Consider this the official announcement of
the end-of-life of fedfs-utils.


--
Chuck Lever



