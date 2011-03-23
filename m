Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53408 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751073Ab1CWJkp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Mar 2011 05:40:45 -0400
Message-ID: <4D89C05F.50208@cn.fujitsu.com>
Date: Wed, 23 Mar 2011 17:41:51 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 10/17] CLNT: test resues slot ID
References: <4D6DE26C.3010103@cn.fujitsu.com> <4D6DE4A5.1050702@cn.fujitsu.com> <20110303061442.GE7724@fieldses.org> <4D6F5B4E.7000903@cn.fujitsu.com> <4D70AB97.3070502@cn.fujitsu.com> <20110314184144.GB25442@fieldses.org> <20110314192434.GC25442@fieldses.org> <4D7ED324.4070600@cn.fujitsu.com> <20110317225245.GE31845@fieldses.org> <4D886F71.8050001@cn.fujitsu.com> <20110322214839.GA17784@fieldses.org>
In-Reply-To: <20110322214839.GA17784@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



J. Bruce Fields:
> On Tue, Mar 22, 2011 at 05:44:17PM +0800, Mi Jinlong wrote:
>>   I have made a mistake about this case, we don't need the filehandle from GETFHres,
>>   that is just unnecessary.
>>
>>   Thanks for your point about the homedir, 
>>   I found a function named use_obj at nfs4lib which can solve our problem.
>>
>>   After fixed, maybe the following patch is OK now.
> 
> Great, thanks--applied.
> 
> At this point I've applied and pushed out everything I've taken from
> you.

  Thanks.

> 
> So let me know what else you still have that's not in my git repo.  I
> know there are the reclaim_complete tests that you're still looking
> at, but there might also be a few other odd tests that I still had
> questions about?

  No. Just those tests about reclaim_complete.

  Maybe I have meet some other problem about pynfs41 tests, 
  I will send the fixing out after I check out.

-- 
----
thanks
Mi Jinlong

