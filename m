Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:51331 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751395Ab2BTSoS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Feb 2012 13:44:18 -0500
Message-ID: <4F429450.5080502@candelatech.com>
Date: Mon, 20 Feb 2012 10:43:28 -0800
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Jim Rees <rees@umich.edu>, Chris Rankin <rankincj@yahoo.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [OOPS] NFS dereferenced NULL pointer with 3.2.6 kernel.
References: <4F4194C4.40104@yahoo.com>  <1329760844.2834.1.camel@lade.trondhjem.org>  <20120220182709.GA22899@umich.edu> <1329762949.5151.8.camel@lade.trondhjem.org>
In-Reply-To: <1329762949.5151.8.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/20/2012 10:35 AM, Myklebust, Trond wrote:
> On Mon, 2012-02-20 at 13:27 -0500, Jim Rees wrote:
>> Myklebust, Trond wrote:
>>
>>    It's a known bug. There is a fix at
>>
>>    http://git.linux-nfs.org/?p=trondmy/nfs-2.6.git;a=commit;h=331818f1c468a24e581aedcbe52af799366a9dfe
>>
>> Shouldn't this be in stable by now?  You sent it Feb 3, and there have been
>> two stable releases since then.
>
> I've been waiting for Andy to get back from vacation. We've already sent
> one buggy patch to stable...
>

It's still not in 3.3-rc either, at least put it there so others
can test it?

I've been testing with the patch applied to 3.3 and it fixes
the crashes for me....

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

