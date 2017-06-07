Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36728 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751321AbdFGPzu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Jun 2017 11:55:50 -0400
Date: Wed, 7 Jun 2017 11:55:49 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Cc: fedfs-utils developers <fedfs-utils-devel@oss.oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Proposal for end-of-life for fedfs-utils development
Message-ID: <20170607155549.GB26995@fieldses.org>
References: <56804FBE-34B2-47FB-96EF-013D4476D89A@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <56804FBE-34B2-47FB-96EF-013D4476D89A@oracle.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So if it's not too depressing I'd be curious what went wrong--did this
turn out to be harder than we thought to get stable, or are people happy
enough with automounting, or did we just not do a good job of explaining
it to people that might use it, or some combination of all those?

--b.

On Fri, Jun 02, 2017 at 11:01:05AM -0400, Chuck Lever wrote:
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
> 
> 
> --
> Chuck Lever
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
