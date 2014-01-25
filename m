Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:57146 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751558AbaAYOjf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 25 Jan 2014 09:39:35 -0500
Message-ID: <52E3CC9F.5060102@RedHat.com>
Date: Sat, 25 Jan 2014 09:39:27 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Sebastien Godard <sysstat@orange.fr>, NeilBrown <neilb@suse.de>
CC: Chuck Lever <chuck.lever@oracle.com>, varekova@redhat.com,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Too many programs called nfsiostat.
References: <20130410094639.5debfc90@notabene.brown>	<20140121144517.5f549347@notabene.brown>	<A5BFEC5C-7AF2-4A7E-856F-D62F35BCEFC0@oracle.com>	<20140122112436.574f0e29@notabene.brown>	<52DFC3C3.7080506@RedHat.com> <20140123085226.72ebaf85@notabene.brown> <52E15495.3050103@RedHat.com> <52E17790.4090903@orange.fr>
In-Reply-To: <52E17790.4090903@orange.fr>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 23/01/14 15:12, Sebastien Godard wrote:
> On 01/23/2014 06:42 PM, Steve Dickson wrote:
>>
>> On 22/01/14 16:52, NeilBrown wrote:
>>> On Wed, 22 Jan 2014 08:12:35 -0500 Steve Dickson <SteveD@redhat.com> wrote:
>>>
>>>>
>>>> On 21/01/14 19:24, NeilBrown wrote:
>>>> Is this version still actively being maintain? 
>>> Last change was 5 days ago.
>>>
>>> https://github.com/sysstat/sysstat/commits/master/nfsiostat.c
>> I guess the question now is do they want to continue maintaining
>> it or just merge the functionality into the nfs-utils version...
>>
> 
> This is no longer a question as I already answered it. Please *read* my previous mail.
I did... but thought Neil's mail was pointing out that some type of 
maintenance was happening... But if you say it's "no longer actively being maintained"
I'll believe you... :-) 

So what is the next step to deprecate the nfsiostat in sysstat? 

steved.

> 
> Regards,
> 
