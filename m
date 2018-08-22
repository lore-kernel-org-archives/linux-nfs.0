Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lisa.pbhware.com ([96.251.22.156]:29160 "EHLO lisa.pbhware.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727821AbeHVWyk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 22 Aug 2018 18:54:40 -0400
Subject: Re: nfs4-acl-tools 0.3.5
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
References: <20180807193736.GA18187@fieldses.org>
 <20180821165130.GA14413@fieldses.org>
 <5fa4b700-3d45-cda3-37ed-bdfbd427574d@acm.org>
 <20180822003301.GA17500@fieldses.org>
 <d4649560-ad74-d119-13ba-876af9a4974e@acm.org>
 <20180822151213.GA24172@fieldses.org>
From: "Paul B. Henson" <henson@acm.org>
Message-ID: <c1b05b61-b85e-7dff-8cff-12b85bffb3c6@acm.org>
Date: Wed, 22 Aug 2018 12:28:13 -0700
MIME-Version: 1.0
In-Reply-To: <20180822151213.GA24172@fieldses.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 8/22/2018 8:12 AM, J. Bruce Fields wrote:
> 
> Huh.  Yeah, that does look like a bug.  But I'm surprised the utilities
> would work at all in that case--I'd expect both the Solaris and Linux
> knfsd to reject an ACL with those extra bits, and certainly neither

Hmm, you're right; trying to include any of them when updating an ACL on 
an illumos server from the Linux client results in "Failed setxattr 
operation: Invalid argument".

It looks like those extra flags aren't even documented. Given a server 
will never actually return them such that a user sees them displayed, 
and they are not documented, it's most likely no one has ever actually 
tried to use them 8-/. From a historical perspective, it would be 
interesting to know why they are there, but that is perhaps lost to 
antiquity ;).

> I suspect they're unnecessary, and I'd happily take a patch to remove
> them once we figure out what's going on.

I'll strip them out and send you a patch soon; hopefully it won't take 
10 more years to show up in a release :).

A side question while I have your attention; once I get the ZFS NFSv4 
acl support committed upstream, what is it going to take to have the 
linux NFSv4 server use them and provide them to clients?

Thanks much…
