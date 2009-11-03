From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: Re: [RFC] NLM server can not process retransmited request correctly
Date: Tue, 03 Nov 2009 17:37:22 +0800
Message-ID: <4AEFF9D2.8030506@cn.fujitsu.com>
References: <4AEEA622.6000705@cn.fujitsu.com> <20091102200956.GC19271@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	NFSv3 list <linux-nfs@vger.kernel.org>, mingo@elte.hu
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61270 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754153AbZKCJgR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Nov 2009 04:36:17 -0500
In-Reply-To: <20091102200956.GC19271@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce

 Thanks for your answer.

J. Bruce Fields:
> On Mon, Nov 02, 2009 at 05:28:02PM +0800, Mi Jinlong wrote:
>> Hi Trond et al:
>>

..snip..

>>    Server reply ENOLCK for WL1 to client because nfslock service stoped,
> 
> I don't completely understand that part: is it because the monitor call
> to statd fails?

yes. 

> 
>>    but it can not distinguish retransmited request with normal request, 
>>    so it reply OK for WL1_re to client after nfslock service start. But 
>>    fcntl client called will return when it receive WL1.reply, WL1_re.reply
>>    will be droped at Client. So that, the lock between client and server
>>    is different. When client send a some lock request to server again,
>>    it will get a EBLOCKD error from Server.
> 
> But, OK, I get the idea, and generic DRC code shared by nfsd and nlm
> makes sense to me; thanks for looking into this.

In my patch, the generic DRC code as a part of sunrpc, is it ok? or we
should put it at fs/nfs_common?

-----
Regards
Mi Jinlong

