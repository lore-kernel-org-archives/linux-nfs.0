Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15293 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751819Ab1FHDMx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jun 2011 23:12:53 -0400
Message-ID: <4DEEE8B1.8040001@RedHat.com>
Date: Tue, 07 Jun 2011 23:12:49 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Ben Greear <greearb@candelatech.com>
CC: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Fix build on Fedora 13.
References: <1307469531-20595-1-git-send-email-greearb@candelatech.com> <E9E39B04-8045-44EF-970B-A1F1779C5A69@oracle.com> <4DEE6CEA.8000909@candelatech.com> <4DEE9C55.4040805@candelatech.com>
In-Reply-To: <4DEE9C55.4040805@candelatech.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 06/07/2011 05:47 PM, Ben Greear wrote:
> On 06/07/2011 11:24 AM, Ben Greear wrote:
>> On 06/07/2011 11:14 AM, Chuck Lever wrote:
>>> Hi Ben-
>>>
>>> On Jun 7, 2011, at 1:58 PM, greearb@candelatech.com wrote:
>>>
>>>> From: Ben Greear<greearb@candelatech.com>
>>>>
>>>> Need sys/stat.h for S_ISDIR and S_ISREG symbols.
>>>
>>> Can you tell when this problem was introduced? What ./configure
>>> options might be relevant?
>>
>> I haven't compiled nfs-utils in years. Since I can't get ./configure to
>> find libgssapi,
>> I'm compiling with:
>>
>> ./configure --disable-gss
> 
> I think I was given a bad git repo suggestion in a previous email.
> 
> I was using:  git://git.infradead.org/users/steved/nfs-utils.git
> which hasn't been updated in years.
> 
> Let me start all over again with
> git://git.linux-nfs.org/projects/steved/nfs-utils.git
Here is the correct path:
    git://linux-nfs.org/~steved/exports/nfs-utils

steved.

