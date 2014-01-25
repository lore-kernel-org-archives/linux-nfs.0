Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp07.smtpout.orange.fr ([80.12.242.129]:40926 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277AbaAYPp6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 25 Jan 2014 10:45:58 -0500
Message-ID: <52E3DC2C.1050400@orange.fr>
Date: Sat, 25 Jan 2014 16:45:48 +0100
From: Sebastien Godard <sysstat@orange.fr>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>, NeilBrown <neilb@suse.de>
CC: Chuck Lever <chuck.lever@oracle.com>, varekova@redhat.com,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Too many programs called nfsiostat.
References: <20130410094639.5debfc90@notabene.brown>	<20140121144517.5f549347@notabene.brown>	<A5BFEC5C-7AF2-4A7E-856F-D62F35BCEFC0@oracle.com>	<20140122112436.574f0e29@notabene.brown>	<52DFC3C3.7080506@RedHat.com> <20140123085226.72ebaf85@notabene.brown> <52E15495.3050103@RedHat.com> <52E17790.4090903@orange.fr> <52E3CC9F.5060102@RedHat.com>
In-Reply-To: <52E3CC9F.5060102@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/25/2014 03:39 PM, Steve Dickson wrote:
>
> On 23/01/14 15:12, Sebastien Godard wrote:
>> On 01/23/2014 06:42 PM, Steve Dickson wrote:
>>> On 22/01/14 16:52, NeilBrown wrote:
>>>> On Wed, 22 Jan 2014 08:12:35 -0500 Steve Dickson <SteveD@redhat.com> wrote:
>>>>
>>>>> On 21/01/14 19:24, NeilBrown wrote:
>>>>> Is this version still actively being maintain?
>>>> Last change was 5 days ago.
>>>>
>>>> https://github.com/sysstat/sysstat/commits/master/nfsiostat.c
>>> I guess the question now is do they want to continue maintaining
>>> it or just merge the functionality into the nfs-utils version...
>>>
>> This is no longer a question as I already answered it. Please *read* my previous mail.
> I did... but thought Neil's mail was pointing out that some type of
> maintenance was happening... But if you say it's "no longer actively being maintained"
> I'll believe you... :-)
>
> So what is the next step to deprecate the nfsiostat in sysstat?
>

In fact, the various patches applied to nfsiostat over the last few 
years were mainly cosmetic ones (changes in sysstat APIs, etc.)
So I propose now to simply remove nfsiostat code from sysstat: Next 
sysstat version will rename nfsiostat (eg. to nfsiostat-sysstat) and the 
man page will indicate it is now obsolete and point to the version from 
nfs-utils. Then nfsiostat will be definitively removed sometime before 
the end of this year.

Regards,

-- 
Sebastien GODARD <sysstat [at] orange.fr>
http://sebastien.godard.pagesperso-orange.fr/

