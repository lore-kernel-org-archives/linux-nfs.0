Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:47223 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885Ab1FJQXk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 12:23:40 -0400
Message-ID: <4DF2450A.6000704@panasas.com>
Date: Fri, 10 Jun 2011 09:23:38 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: tao.peng@emc.com, bergwolf@gmail.com, rees@umich.edu,
        linux-nfs@vger.kernel.org, honey@citi.umich.edu
Subject: Re: [PATCH 87/88] Add configurable prefetch size for layoutget
References: <cover.1307464381.git.rees@umich.edu> <09142112ff0115f7f22124a69ead7b9bb5e0958f.1307464382.git.rees@umich.edu> <4DEED80A.4000102@panasas.com> <20110608021852.GA20998@merit.edu> <BANLkTi=HcQcGbTKTq2MSg8XeW=fKwG4-tw@mail.gmail.com> <4DF062D6.7010304@panasas.com> <BANLkTi=SMQhUNHEy=-ZPqFtCgKcnCtks=w@mail.gmail.com> <4DF13B65.5030401@panasas.com> <F19688880B763E40B28B2B462677FBF805BED9D222@MX09A.corp.emc.com> <4DF21267.9060706@panasas.com>
In-Reply-To: <4DF21267.9060706@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/10/2011 05:47 AM, Benny Halevy wrote:
> On 2011-06-10 02:02, tao.peng@emc.com wrote:
>> Hi, Benny,
>>
>> Cheers,
>> -Bergwolf
>>
>>
>> -----Original Message-----
>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Benny Halevy
>> Sent: Friday, June 10, 2011 5:30 AM
>> To: Peng Tao
>> Cc: Jim Rees; linux-nfs@vger.kernel.org; peter honeyman
>> Subject: Re: [PATCH 87/88] Add configurable prefetch size for layoutget
>>
>> On 2011-06-09 07:54, Peng Tao wrote:
>>> On Thu, Jun 9, 2011 at 2:06 PM, Benny Halevy <bhalevy@panasas.com> wrote:
>>>> On 2011-06-08 03:15, Peng Tao wrote:
>>>>> On 6/8/11, Jim Rees <rees@umich.edu> wrote:
>>>>>> Benny Halevy wrote:
>>>>>>
>>>>>>   NAK.
>>>>>>   This affects all layout types.  In particular it is undesired
>>>>>>   for write layouts that extend the file with the objects layout.
>>>>>>   The server can extend the layout segments range
>>>>>>   over what the client requested so why would the client
>>>>>>   ask for artificially large layouts?
>>>>>>
>>>>>> This has actually been the subject of some debate over Thursday night
>>>>>> beers.  The problem we're trying to solve is that the client is spending 98%
>>>>>> of its time in layoutget.  This patch gives us something like a 10x
>>>>>> speedup.  But many of us think it's not the right fix.  I suggest we discuss
>>>>>> next week.
>>>>>>
>>>>
>>>> Sure.
>>>>
>>>>>> But note that this patch doesn't change anything unless you set the sysctl.
>>>>> there is a default value of 2M. maybe we can set it to page size by
>>>>> default so other layout are not affected and block layout can let
>>>>> users set it by hand if they care about performance. does this make
>>>>> sense?
>>>>
>>>> If doing it at all why use a sysctl rather than a mount option?
>>> The purpose of using a sysctl is to give client the ability to change
>>> it on the fly. In theory, layout prefetching can benefit all layout
>>> types. So the patch tries to solve it in the pnfs generic layer.
>>>
>>
>> But the need for this varies per-server and many times per application.
>> Think sequential vs. random I/O.  Therefore a mount option would help
>> tuning the behavior on a per-use basis.  Global behavior must be implemented
>> using a dynamic algorithm that would take both the workload and the server
>> observed behavior into account.
>> [PT] Indeed. Dynamic algorithm is supposed to be able to solve all this. And it often takes longer to be designed/accepted. It has to prove to be better in most scenarios and does not hurt the left.
> 
> We need to find an acceptable solution to push this driver upstream.
> I understand that developing a dynamic algorithm in the given time frame is
> too big of a challenge, but hacking yet another client tunable is out of the
> question either.   For testing in the Bakeathon I'd consider taking a DEVONLY version
> of this patch that is enabled using a config option and defaults to zero to have no effect
> in run-time until the sysctl is sets it differently.
> But keep in mind this is not suitable for pushing upstream.
> 

I disagree. Please make that same exact patch for the server you are using!

Leave the client alone. Don't even consider getting use to this, sticking
broken stuff on client scripts. If anywhere it should be in Server configuration
files

Boaz

> Benny
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

