Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:39849 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752479Ab2FKPfL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jun 2012 11:35:11 -0400
Message-ID: <4FD6101A.7060502@panasas.com>
Date: Mon, 11 Jun 2012 18:34:50 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Benny Halevy <bhalevy@tonian.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [RFC] Something very wrong with layout_recall of RETURN_FILE
References: <4FC6B29C.3030803@panasas.com> <4FD60A78.8060604@tonian.com>
In-Reply-To: <4FD60A78.8060604@tonian.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/11/2012 06:10 PM, Benny Halevy wrote:

> This should be fixed regardless so that exofs is more tolerant to "phantom"
> layout returns.
> 


It's not a crash at exofs, it's a crash at nfsd do to reference miss-match.


<>

> This wasn't the original intent for cl_has_file_layout.
> 
> I agree the requirement changed when we added the cookie magic
> and the reliance of exofs on the layout recall process to be
> precise about detecting the no layout case.  So on one hand
> the process needs to be more robust and on the other we can
> lookup the exact region as you suggest below.
> 


I have lots of code changes to this, which works very well, to
my satisfaction. It fixes the above and many other problems
and is also a cleanup and fixture additions.

I would have sent it, if I was not busy with clients bugs found
which are more urgent. The code is there and is being heavily
tested as we speak. (mainly the client code, the server code is
very good)

It'll take a few more days to send all this, in. Needs SPLITMEs
and cleanup. (Tell me if you want RFC level code which will be
harder for review, before hand)

> Then, we should be able to get rid of the layout states list altogether.
> (practically reverting "pnfsd: layout recall layout state")
> 


I have not removed this. As you say it's by now dead code. I'll send in
what I have and we can surgically revert that thing as well. It will
all be in SQUASHMEs and we can later re-arrange the patches for this
to naturally fall off the patchlist. (I intend to help a bit with this
work, in the areas these touch)

> Benny
> 


Thanks
Boaz

