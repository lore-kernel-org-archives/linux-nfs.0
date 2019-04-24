Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09AF3C282CE
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 15:30:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DCB8321904
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 15:30:03 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731217AbfDXPaC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 11:30:02 -0400
Received: from mx1.redhat.com ([209.132.183.28]:39052 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730534AbfDXPaB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 24 Apr 2019 11:30:01 -0400
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 25447C7CAE;
        Wed, 24 Apr 2019 15:30:01 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (madhat.boston.devel.redhat.com [10.19.60.33])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 138601A92D;
        Wed, 24 Apr 2019 15:29:59 +0000 (UTC)
Subject: Re: [PATCH v2 1/2] nfsd: wake waiters blocked on file_lock before
 deleting it
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        NeilBrown <neilb@suse.com>
Cc:     Jeff Layton <jlayton@kernel.org>, slawek1211@gmail.com,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        Steve French <smfrench@gmail.com>
References: <20190422163424.19402-1-jlayton@kernel.org>
 <20190422163424.19402-2-jlayton@kernel.org>
 <87wojl61s5.fsf@notabene.neil.brown.name>
 <20190424135854.GB20542@fieldses.org>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <2b131f18-1df4-790c-a548-3155a0677c34@RedHat.com>
Date:   Wed, 24 Apr 2019 11:29:59 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190424135854.GB20542@fieldses.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Wed, 24 Apr 2019 15:30:01 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 4/24/19 9:58 AM, J. Bruce Fields wrote:
> Steve, see Neil's comment, is there a cifs bug here?
Looking into it... 

steved.
> 
> --b.
> 
> On Tue, Apr 23, 2019 at 09:47:06AM +1000, NeilBrown wrote:
>> On Mon, Apr 22 2019, Jeff Layton wrote:
>>
>>> After a blocked nfsd file_lock request is deleted, knfsd will send a
>>> callback to the client and then free the request. Commit 16306a61d3b7
>>> ("fs/locks: always delete_block after waiting.") changed it such that
>>> locks_delete_block is always called on a request after it is awoken,
>>> but that patch missed fixing up blocked nfsd request handling.
>>>
>>> Call locks_delete_block on the block to wake up any locks still blocked
>>> on the nfsd lock request before freeing it. Some of its callers already
>>> do this however, so just remove those calls.
>>>
>>> URL: https://bugzilla.kernel.org/show_bug.cgi?id=203363
>>> Fixes: 16306a61d3b7 ("fs/locks: always delete_block after waiting.")
>>> Reported-by: Slawomir Pryczek <slawek1211@gmail.com>
>>> Cc: Neil Brown <neilb@suse.com>
>>> Cc: stable@vger.kernel.org
>>> Signed-off-by: Jeff Layton <jlayton@kernel.org>
>>> ---
>>>  fs/nfsd/nfs4state.c | 3 +--
>>>  1 file changed, 1 insertion(+), 2 deletions(-)
>>>
>>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>>> index 6a45fb00c5fc..e87e15df2044 100644
>>> --- a/fs/nfsd/nfs4state.c
>>> +++ b/fs/nfsd/nfs4state.c
>>> @@ -265,6 +265,7 @@ find_or_allocate_block(struct nfs4_lockowner *lo, struct knfsd_fh *fh,
>>>  static void
>>>  free_blocked_lock(struct nfsd4_blocked_lock *nbl)
>>>  {
>>> +	locks_delete_block(&nbl->nbl_lock);
>>>  	locks_release_private(&nbl->nbl_lock);
>>
>> Thanks for tracking this down.
>>
>> An implication of this bug and fix is that we need to be particularly
>> careful to make sure locks_delete_block() is called on all relevant
>> paths.
>> Can we make that easier?  My first thought was to include the call in
>> locks_release_private, but lockd calls the two quite separately and it
>> certainly seems appropriate that locks_delete_block should be called
>> asap, but locks_release_private() can be delayed.
>>
>> Also cifs calls locks_delete_block, but never calls
>> locks_release_private, so it wouldn't help there.
>>
>> Looking at cifs, I think there is a call missing there too.
>> cifs_posix_lock_set() *doesn't* always call locks_delete_block() after
>> waiting.  In particular, if ->can_cache_brlcks becomes true while
>> waiting then I don't think the behaviour is right.... though I'm not
>> sure it is right for other reasons.  It looks like the return value
>> should be 1 in that case, but it'll be zero.
>>
>> But back to my question about making it easier, move the BUG_ON()
>> calls from locks_free_lock() into locks_release_private().
>>
>> ??
>>
>> Thanks,
>> NeilBrown
>>
>>
>>>  	kfree(nbl);
>>>  }
>>> @@ -293,7 +294,6 @@ remove_blocked_locks(struct nfs4_lockowner *lo)
>>>  		nbl = list_first_entry(&reaplist, struct nfsd4_blocked_lock,
>>>  					nbl_lru);
>>>  		list_del_init(&nbl->nbl_lru);
>>> -		locks_delete_block(&nbl->nbl_lock);
>>>  		free_blocked_lock(nbl);
>>>  	}
>>>  }
>>> @@ -4863,7 +4863,6 @@ nfs4_laundromat(struct nfsd_net *nn)
>>>  		nbl = list_first_entry(&reaplist,
>>>  					struct nfsd4_blocked_lock, nbl_lru);
>>>  		list_del_init(&nbl->nbl_lru);
>>> -		locks_delete_block(&nbl->nbl_lock);
>>>  		free_blocked_lock(nbl);
>>>  	}
>>>  out:
>>> -- 
>>> 2.20.1
> 
> 
