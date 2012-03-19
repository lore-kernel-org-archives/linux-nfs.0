Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:48841 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754399Ab2CSXYN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Mar 2012 19:24:13 -0400
Message-ID: <4F67BFE9.5040809@panasas.com>
Date: Mon, 19 Mar 2012 16:23:21 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>,
        "Bhamare, Sachin" <sbhamare@panasas.com>,
        Benny Halevy <bhalevy@tonian.com>, Steve Dickson <steved@redhat.com>,
        "Welch, Brent" <welch@panasas.com>
Subject: Re: [PATCH 3/4] pnfs-obj: autologin: Add support for protocol autologin
References: <4F62DADD.3010502@panasas.com> <4F62DC6A.5080709@panasas.com>  <1331934052.13255.7.camel@lade.trondhjem.org>  <4F679DEF.3040002@panasas.com> <1332191559.2636.34.camel@lade.trondhjem.org>
In-Reply-To: <1332191559.2636.34.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/19/2012 02:12 PM, Myklebust, Trond wrote:
> On Mon, 2012-03-19 at 13:58 -0700, Boaz Harrosh wrote:
>> On 03/16/2012 02:40 PM, Myklebust, Trond wrote:
>>> On Thu, 2012-03-15 at 23:23 -0700, Boaz Harrosh wrote:
>>>> From: Sachin Bhamare <sbhamare@panasas.com>
>>>>
>>>> The pnfs-objects protocol mandates that we autologin into devices not
>>>> present in the system, according to information specified in the
>>>> get_device_info returned from the server.
>>>>
>>>> The Protocol specifies two login hints.
>>>> 1. An IP address:port combination
>>>> 2. A string URI which is constructed as a URL with a protocol prefix
>>>>    followed by :// and a string as address. For each  protocol prefix
>>>>    the string-address format might be different.
>>>>
>>>> We only support the second option. The first option is just redundant
>>>> to the second one.
>>>> NOTE: The Kernel part of autologin does not parse the URI string. It
>>>> just channels it to a user-mode script. So any new login protocols should
>>>> only update the user-mode script which is a part of the nfs-utils package,
>>>> but the Kernel need not change.
>>>>
>>>> We implement the autologin by using the call_usermodehelper() API.
>>>> (Thanks to Steve Dickson <steved@redhat.com> for pointing it out)
>>>> So there is no running daemon needed, and or special setup.
>>>>
>>>> All is needed is that "/sbin/osd_login" script exists.
>>>> TODO:
>>>>   "osd_login" is an hard coded name. If not present we will rate_limit
>>>>   print to dmsg and keep failing. In such cases we should stop trying
>>>>   and provide sysfs interface for re-enabling autologin. For example,
>>>>   we could ZERO out the script name and let user-mode set a new script
>>>>   name.
>>>>   [Q] Where in sysfs should a layout-driver put its things?
>>>
>>> Please see fs/nfs/cache_lib.c, which already does this sort of thing.
>>> The right thing to do is not sysfs, but a kernel module parameter.
>>>
>>
>> I have a question about the "kernel module parameter" is that an hot
>> affair. I mean if the module is loaded, does it have to be unloaded
>> before I can specify a new "module parameter" on load. Or it will
>> update globally even if the module is already loaded?
>>
>> The reason I'm asking is because the layout-driver is referenced
>> by nfs-core on mount. And will not release until unmount, of the
>> last pnf-objects mount-point.
>>
>> That's why I thought of a /sys so all mount-points need not be unmounted
>> before admin can fix the problem.
> 
> Yes. If you design things correctly, you can make the kernel parameter
> writeable by setting the mode in the module_param_string(). Again,
> please see fs/nfs/cache_lib.c.
> 
> The advantage of the kernel parameter here is that you can initialise it
> directly in /etc/modprobe.conf using the 'options' command, but you can
> later change it dynamically (without removing the module) using the
> pseudofile in /sys/module/objlayout-driver/parameters
> 

Perfect thanks. Done. I'll send the patch soon. Am now testing it.
I want to test all the possible options and the dynamic change.

Thanks
Boaz
 
