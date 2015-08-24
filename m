Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:33823 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755098AbbHXVZx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Aug 2015 17:25:53 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH v2 0/2] nfsd: fix unhashing races in nfsv4 stateid
 handling
To: Jeff Layton <jlayton@poochiereds.net>, <bfields@fieldses.org>
References: <1440434508-16046-1-git-send-email-jeff.layton@primarydata.com>
CC: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Andrew W Elble <aweits@rit.edu>, <linux-nfs@vger.kernel.org>
Message-ID: <55DB8BD9.7090109@Netapp.com>
Date: Mon, 24 Aug 2015 17:25:45 -0400
MIME-Version: 1.0
In-Reply-To: <1440434508-16046-1-git-send-email-jeff.layton@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff,

On 08/24/2015 12:41 PM, Jeff Layton wrote:
> v2:
> - fix the fault injection code to handle the prototype change to
>   unhash_lock_stateid
> 
> Slightly updated set, to fix a problem that Wu found when enabling the
> nfsd fault injection code. Original cover-letter follows:
> 
> -------------------------[snip]-------------------
> 
> I hadn't heard from Andrew in a while so I'm not 100% clear on whether
> his patches had fixed the race that he had spotted in the NFSv4
> unhashing code.
> 
> Still, once he had done the analysis, the problem was clear. I think
> this patchset should fix the problem in a relatively clean way. I've
> run some tests against this and it seems to not have broken anything,
> but I haven't been able to reproduce the actual race so I can't
> verify that this fixes it.
> 
> Andrew, Anna, if you are able to do so could you test these patches
> and let us know whether this fixes those races?

I just did a quick test, and it looks like my problem has been fixed.  I'll do more in-depth testing tomorrow, just to make sure.

Thanks for working on this!

Anna
> 
> Jeff Layton (2):
>   nfsd: ensure that the ol stateid hash reference is only put once
>   nfsd: ensure that delegation stateid hash references are only put once
> 
>  fs/nfsd/nfs4state.c | 84 +++++++++++++++++++++++++++++++++--------------------
>  1 file changed, 53 insertions(+), 31 deletions(-)
> 

