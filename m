Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59682 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755653Ab0HCJNW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Aug 2010 05:13:22 -0400
Message-ID: <4C57DD66.1070001@cn.fujitsu.com>
Date: Tue, 03 Aug 2010 17:12:06 +0800
From: Bian Naimeng <biannm@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Revert "nfsd4: distinguish expired from stale stateids"
References: <20100518233746.GC26911@fieldses.org> <4C563CE5.1010101@cn.fujitsu.com> <20100802135036.GA12637@fieldses.org>
In-Reply-To: <20100802135036.GA12637@fieldses.org>
Content-Type: text/plain; charset=Shift_JIS
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> On Mon, Aug 02, 2010 at 11:35:01AM +0800, Bian Naimeng wrote:
>>> From: J. Bruce Fields <bfields@citi.umich.edu>
>>>
>>> This reverts commit 78155ed75f470710f2aecb3e75e3d97107ba8374.

   ... snip ...

>>>
>>   Hi bruce, if remove this patch, some my test will fail. So what's your opinion
>>   for those test case.
>>
>>     STEP1: open the file, and get a open stateid (STATEID).
>>     STEP2: shutdown the network between client and server
>>     STEP3: keep the network partition lease_time(90s by default) seconds
>>     STEP4: recovery network
>>     STEP5: do some IO operation, such as LOCK.
>>
>>   If i use the patch 78155ed75f470710f2aecb3e75e3d97107ba8374, this case will OK
>>   at STEP5,  however, it's will fail when remove this patch.
> 
> How does it fail, exactly?
> 

  My client is linux-2.6.32, server is linux-2.6.35.

  At step5, client will use the old open stateid to send lock request, and server
  return NFS4ERR_BAD_STATEID  because this stateid have be released, 
  then client's kernel return EIO to userspace.

  If i apply this patch, server will return NFS4ERR_EXPIRED at step5, then client
  will start recovery procedure.

>>   So i think it's no good for the network recovery, what do you think about it, 
>>   or give me some suggestions, thanks very much.
> 
> The theoretical problem with the patch is that time changes could cause
> the server to return spurious errors when the client hands it state that
> should still be good.
> 

  En... Would you give me a example?

> We might be able to solve that by using a different time source?
> 

  As i see, this question is difficult to slove. Freebsd looks like nerver return 
  the NFSERR_EXPIRED error.  And solaris more than happy to return NFSERR_EXPIRED 
  rather than NFSERR_BAD_STATEID when the stateid is not found at server.

  I mean it's difficult to distinguish expired_stateid and bad_stateid(they are not
  exist at server), so maybe we have not a exactly solution to solve it.

  Maybe we should choose which error we are more needed, NFSERR_EXPIRED  or NFSERR_BAD_STATEID?

-- 
Regards
Bian Naimeng

