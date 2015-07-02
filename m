Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49458 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752916AbbGBHuP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jul 2015 03:50:15 -0400
Date: Thu, 2 Jul 2015 08:50:08 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
        Eric Van Hensbergen <ericvh@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: running out of tags in 9P (was Re: [git pull] vfs part 2)
Message-ID: <20150702075007.GH17109@ZenIV.linux.org.uk>
References: <20150701062752.GC17109@ZenIV.linux.org.uk>
 <55939BE3.6040902@samsung.com>
 <20150701082753.GD17109@ZenIV.linux.org.uk>
 <5593A7A0.6050400@samsung.com>
 <20150701085507.GE17109@ZenIV.linux.org.uk>
 <5593CE37.4070307@samsung.com>
 <20150701184408.GF17109@ZenIV.linux.org.uk>
 <20150702032042.GA32613@ZenIV.linux.org.uk>
 <20150702041046.GG17109@ZenIV.linux.org.uk>
 <5594E5EB.4030808@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5594E5EB.4030808@samsung.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 02, 2015 at 10:19:07AM +0300, Andrey Ryabinin wrote:
> On 07/02/2015 07:10 AM, Al Viro wrote:
> >>
> >> It should be easy to confirm - in p9_client_prepare_req() add
> >> 		if (WARN_ON_ONCE(tag != (u16)tag)) {
> >> 			p9_idpool_put(tag, c->tagpool);
> >> 			return ERR_PTR(-ENOMEM);
> >> 		}
> >> right after
> >>                 tag = p9_idpool_get(c->tagpool);
> >>                 if (tag < 0)
> >>                         return ERR_PTR(-ENOMEM);
> >>
> >> and see if it triggers.  I'm not sure if failing with ENOMEM is the
> >> right response (another variant is to sleep there until the pile
> >> gets cleaned or until we get killed), and WARN_ON_ONCE() is definitely
> >> not for the real work, but it will do for confirming that this is what
> >> we are hitting.
> > 
> 
> Apparently, I'm seeing something else. That WARN_ON_ONCE didn't trigger.

While the one in p9_client_write() (on rsize < count) did?
