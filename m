Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40347 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751656AbaAWRmy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Jan 2014 12:42:54 -0500
Message-ID: <52E15495.3050103@RedHat.com>
Date: Thu, 23 Jan 2014 12:42:45 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: Chuck Lever <chuck.lever@oracle.com>, varekova@redhat.com,
        sysstat@orange.fr, Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Too many programs called nfsiostat.
References: <20130410094639.5debfc90@notabene.brown>	<20140121144517.5f549347@notabene.brown>	<A5BFEC5C-7AF2-4A7E-856F-D62F35BCEFC0@oracle.com>	<20140122112436.574f0e29@notabene.brown>	<52DFC3C3.7080506@RedHat.com> <20140123085226.72ebaf85@notabene.brown>
In-Reply-To: <20140123085226.72ebaf85@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 22/01/14 16:52, NeilBrown wrote:
> On Wed, 22 Jan 2014 08:12:35 -0500 Steve Dickson <SteveD@redhat.com> wrote:
> 
>>
>>
>> On 21/01/14 19:24, NeilBrown wrote:
>>> On Tue, 21 Jan 2014 10:40:01 -0500 Chuck Lever <chuck.lever@oracle.com> wrote:
>>>
>>>>
>>>> On Jan 20, 2014, at 10:45 PM, NeilBrown <neilb@suse.de> wrote:
>>>>
>>>>>
>>>>> (This time without the typo in Chuck's address - sorry).
>>>>>
>>>>> Not quite a year ago I wrote:
>>>>>
>>>>> On Wed, 10 Apr 2013 09:46:39 +1000 NeilBrown <neilb@suse.de> wrote:
>>>>>
>>>>>>
>>>>>> Hi all,
>>>>>> it seems that in 2010, a program called nfsiostat was added to the sysstat
>>>>>> package (http://sebastien.godard.pagesperso-orange.fr/)
>>>>>>
>>>>>> This is unfortunate because in 2008 a program called nfsiostat was added to
>>>>>> the nfs-utils package.
>>>>>>    (https://www.kernel.org/pub/linux/utils/nfs-utils/1.2.7/)
>>>>>>
>>>>>> The default install locations seem to be different (/usr/bin vs /usr/sbin),
>>>>>> so packagers would not immediately notice.
>>>>>>
>>>>>> This seems like something that should be "fixed".
>>>>>>
>>>>>> Any suggestions what a good "fix" should look like?
>>>>>>
>>>>>> NeilBrown
>>>>>
>>>>>
>>>>> No suggestions were forthcoming.
>>>>> So I have a suggestion.
>>>>> I propose we rename the "nfsiostat" in the "sysstat" package to
>>>>> "nfsio-sysstat" and the "nfsiostat" in "nfs-utils" to
>>>>> "nfs-utils-iostat".
>>>>>
>>>>> Does anyone object?  If not I'll send off patches shortly :-)
>>>>
>>>> What does the sysstat version do?  do we need two programs, or can they be merged?  Or can one be dropped?
>>>>
>>>
>>> It reads /proc/self/mountstats and reports some numbers, not unlike the
>>> nfs-utils version.
>>>
>>> $ /usr/sbin/nfsiostat 
>>>
>>> eli:/home mounted on /mnt:
>>>
>>>    op/s		rpc bklog
>>>    3.55	   0.00
>>> read:            ops/s		   kB/s		  kB/op		retrans		avg RTT (ms)	avg exe (ms)
>>> 		  0.000	  0.000	  0.000       0 (0.0%)	  0.000	  0.000
>>> write:           ops/s		   kB/s		  kB/op		retrans		avg RTT (ms)	avg exe (ms)
>>> 		  0.000	  0.000	  0.000       0 (0.0%)	  0.000	  0.000
>>> $ /usr/bin/nfsiostat 
>>> Linux 3.11.6-4-desktop (notabene.brown) 	01/22/2014 	_x86_64_	(8 CPU)
>>>
>>> Filesystem:               rkB_nor/s    wkB_nor/s    rkB_dir/s    wkB_dir/s    rkB_svr/s    wkB_svr/s     ops/s    rops/s    wops/s
>>> eli:/home                      0.00         0.00         0.00         0.00         0.00         0.00      0.00      0.00      0.00
>>>
>>>
>>> The man page for the sysstat version is:
>>>
>>> http://www.makelinux.com/man/1/N/nfsiostat
>> Is this version still actively being maintain? 
> 
> Last change was 5 days ago.
> 
> https://github.com/sysstat/sysstat/commits/master/nfsiostat.c
I guess the question now is do they want to continue maintaining
it or just merge the functionality into the nfs-utils version...

steved.
> 
> NeilBrown
> 
> 
>>
>> steved.
>>
>>>
>>> while man page for nfs-utils version is:
>>>
>>> http://linux.die.net/man/8/nfsiostat
>>>
>>> NeilBrown
>>>
> 
