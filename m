Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60794 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753344Ab0HWHla (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Aug 2010 03:41:30 -0400
Message-ID: <4C7225C5.7060406@cn.fujitsu.com>
Date: Mon, 23 Aug 2010 15:39:49 +0800
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

    ... snip ...

>>   If i use the patch 78155ed75f470710f2aecb3e75e3d97107ba8374, this case will OK
>>   at STEP5,  however, it's will fail when remove this patch.
> 
> How does it fail, exactly?
> 
>>   So i think it's no good for the network recovery, what do you think about it, 
>>   or give me some suggestions, thanks very much.
> 
> The theoretical problem with the patch is that time changes could cause
> the server to return spurious errors when the client hands it state that
> should still be good.
> 
> We might be able to solve that by using a different time source?
> 

  Hi bruce, Have you got a idea to solve it?

-- 
Regards
Bian Naimeng

