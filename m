From: Andy Adamson <andros@netapp.com>
Subject: Re: [pnfs] [PATCH 3/5] nfsd41: reclaim DRC memory on session free
Date: Fri, 31 Jul 2009 04:38:24 -0400
Message-ID: <271F4750-A5E5-457E-977F-B0900A1B86D9@netapp.com>
References: <1245872278-18743-1-git-send-email-andros@netapp.com> <1245872278-18743-2-git-send-email-andros@netapp.com> <1245872278-18743-3-git-send-email-andros@netapp.com> <1245872278-18743-4-git-send-email-andros@netapp.com> <20090716141805.GD30477@fieldses.org> <20090727225735.GF4718@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43469 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751352AbZGaIi1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 Jul 2009 04:38:27 -0400
In-Reply-To: <20090727225735.GF4718@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 27, 2009, at 6:57 PM, J. Bruce Fields wrote:

> On Thu, Jul 16, 2009 at 10:18:05AM -0400, J. Bruce Fields wrote:
>> On Wed, Jun 24, 2009 at 03:37:47PM -0400, andros@netapp.com wrote:
>>> From: Andy Adamson <andros@netapp.com>
>>>
>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>> ---
>>> fs/nfsd/nfs4state.c |    3 +++
>>> 1 files changed, 3 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>>> index b4a536d..991c3cc 100644
>>> --- a/fs/nfsd/nfs4state.c
>>> +++ b/fs/nfsd/nfs4state.c
>>> @@ -583,6 +583,9 @@ free_session(struct kref *kref)
>>> 		struct nfsd4_cache_entry *e = &ses->se_slots[i].sl_cache_entry;
>>> 		nfsd4_release_respages(e->ce_respages, e->ce_resused);
>>> 	}
>>> +	spin_lock(&nfsd_drc_lock);
>>> +	nfsd_drc_mem_used -= ses->se_fchannel.maxreqs *  
>>> NFSD_SLOT_CACHE_SIZE;
>>> +	spin_unlock(&nfsd_drc_lock);
>>> 	kfree(ses);
>>
>> This patch has to be combined with the previous one.
>
> I thought this was fixing a bug from the previous patch!  But  
> instead I
> see this is a fix for a preexisting bugfix.  So better to move this to
> the head of the patch series; applied the following to my for-2.6.32.
>
> Apologies--I've just done this myself and applied the following.  Look
> OK?

Looks fine. Thanks

-->Andy
>
>
> --b.
>
> commit 0a515ffa6f29e9a0f0f60373576bd4d3d5608ae8
> Author: Andy Adamson <andros@netapp.com>
> Date:   Mon Jul 27 18:49:05 2009 -0400
>
>    nfsd41: reclaim DRC memory on session free
>
>    This fixes a leak which would eventually lock out new clients.
>
>    Signed-off-by: Andy Adamson <andros@netapp.com>
>    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 2e6a44e..69bd37e 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -585,6 +585,9 @@ free_session(struct kref *kref)
> 		struct nfsd4_cache_entry *e = &ses->se_slots[i].sl_cache_entry;
> 		nfsd4_release_respages(e->ce_respages, e->ce_resused);
> 	}
> +	spin_lock(&nfsd_drc_lock);
> +	nfsd_drc_pages_used -= ses->se_fchannel.maxreqs *  
> NFSD_PAGES_PER_SLOT;
> +	spin_unlock(&nfsd_drc_lock);
> 	kfree(ses);
> }
>

