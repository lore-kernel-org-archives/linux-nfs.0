Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:64144 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753834Ab1FQNwk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jun 2011 09:52:40 -0400
Received: by vws1 with SMTP id 1so1941792vws.19
        for <linux-nfs@vger.kernel.org>; Fri, 17 Jun 2011 06:52:40 -0700 (PDT)
Message-ID: <4DFB5C23.4010708@tonian.com>
Date: Fri, 17 Jun 2011 09:52:35 -0400
From: Benny Halevy <benny@tonian.com>
To: =?UTF-8?B?5LqO5rWp?= <haohaoweixiao@hotmail.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: In the linux-all-2.6.38 of pnfs, why was pnfs_return_layout removed
 ?
References: <BLU0-SMTP135422B057EEE4C3CA3C9DEAB6A0@phx.gbl>,<4DFA211E.5040103@panasas.com> <SNT136-w5258CE4C76C7D063BA95EBAB6D0@phx.gbl>
In-Reply-To: <SNT136-w5258CE4C76C7D063BA95EBAB6D0@phx.gbl>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On 2011-06-17 08:59, 于浩 wrote:
> Thanks for you reply.
> 
>> What server are you testing?
>> Does the layouts it provides marked with return_on_close?
> Yes, the pnfs I am using is "pnfs-all-2.6.38-2011-03-25 <http://git.linux-nfs.org/?p=bhalevy/linux-pnfs.git;a=tag;h=refs/tags/pnfs-all-2.6.38-2011-03-25>"downloaded 
> from "git://git.linux-nfs.org/projects/bhalevy/linux-pnfs.git".
> 
>> If so, I pulled a patch from Boaz into pnfs-all-2.6.39 for automatically cleaning up
>> return_on_close layouts on the server side after a forgetful client closes the file
>> without returning them.
> Could you send the patch to me? thank you !

That would be
http://git.linux-nfs.org/?p=bhalevy/linux-pnfs.git;a=patch;h=05f980b9dc76a1d12c3774378ceb8ade1e1d4f91

Thanks,

Benny

> Looking forward to your reply.
> 
> Regards,
> Steven.
> 
> ------------------------------------------------------------------------------------------------
> 
>> Date: Thu, 16 Jun 2011 11:28:30 -0400
>> From: bhalevy@panasas.com
>> To: haohaoweixiao@hotmail.com
>> CC: linux-nfs@vger.kernel.org
>> Subject: Re: In the linux-all-2.6.38 of pnfs, why was pnfs_return_layout removed ?
>>
>> Steven, the call was removed to accommodate for the "forgetful client" model
>> where the client drops its layout unilaterally and the server is supposed
>> to clean up the client layout on its side.
>>
>> We are bringing it back, correctly, with proper synchronization, in Linux 3.0
>> in so that the layout will be returned in nfs_evict_inode.
>>
>> What server are you testing?
>> Does the layouts it provides marked with return_on_close?
>> If so, I pulled a patch from Boaz into pnfs-all-2.6.39 for automatically cleaning up
>> return_on_close layouts on the server side after a forgetful client closes the file
>> without returning them.
>>
>> Benny
>>
>> On 2011-06-16 10:52, 于浩 wrote:
>> >
>> > Dear All,
>> > Dear All,
>> > I got one problem when testing the read performance of linux-all-2.6.38. I found that the speed was becoming slower with time.(300MB/s-->50MB/s). Finally,I found the cause of the problem. In __nfs4_close(), the "LAYOUT RETURN" operation was removed. So the size of "layout_hash" becomes bigger and bigger on the pnfs server side. Then more time is spent on searching in __layout_inode_find() function. I wonder why the pnfs_return_layout() in __nfs4_close() was removed ??
>> >
>> > Regards,
>> > Steven.
>> >
>> > ----------------------------------------------------------------------
>> > SQUASHME: pnfs: revert layout recall/get/return synchronization
>> > authorBenny Halevy <bhalevy@panasas.com>
>> > Thu, 24 Feb 2011 02:53:46 +0000 (18:53 -0800)
>> > committerBenny Halevy <bhalevy@panasas.com>
>> > Fri, 25 Mar 2011 08:25:57 +0000 (10:25 +0200)
>> >
>> > For now, revert code attempting a "forget-less" client model to match
>> > the pnfs-submit-wave4 forgetful model implementation in preparation
>> > for porting the tree onto it.
>> >
>> > Signed-off-by: Benny Halevy bhalevy@panasas.com
>> >
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> > the body of a message to majordomo@vger.kernel.org
>> > More majordomo info at http://vger.kernel.org/majordomo-info.html

-- 
Benny Halevy
CTO, Tonian Inc.

Tel: +972-54-802-8340
benny@tonian.com
