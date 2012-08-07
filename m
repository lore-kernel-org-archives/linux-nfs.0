Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36673 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752402Ab2HGTo4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Aug 2012 15:44:56 -0400
Message-ID: <50217035.5010304@netapp.com>
Date: Tue, 07 Aug 2012 15:44:53 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: nfs4 mounts failing with 3.6.0-rc1
References: <20120804000819.GB25558@fieldses.org> <20120803220039.743fe1f0@corrin.poochiereds.net> <20120804190104.GA2135@fieldses.org> <20120807130932.79625d7e@tlielax.poochiereds.net> <20120807194250.GB22532@fieldses.org>
In-Reply-To: <20120807194250.GB22532@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/07/2012 03:42 PM, J. Bruce Fields wrote:
> On Tue, Aug 07, 2012 at 01:09:32PM -0400, Jeff Layton wrote:
>> On Sat, 4 Aug 2012 15:01:04 -0400
>> "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>
>>> On Fri, Aug 03, 2012 at 10:00:39PM -0400, Jeff Layton wrote:
>>>> On Fri, 3 Aug 2012 20:08:19 -0400
>>>> "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>>>
>>>>> I'm getting
>>>>>
>>>>> 	# mount -tnfs -onfsvers=4 pip1:/exports /mnt/
>>>>>
>>>>> (OK, admittedly that's with 3.6.0-rc1 + a few experimental patches, but
>>>>> I doubt they're related.)
>>>>>
>>>>> Also:
>>>>>
>>>>> 	[root@pip2 ~]# modprobe nfs4
>>>>> 	[root@pip2 ~]# lsmod|grep nfs4
>>>>> 	[root@pip2 ~]# 
>>>>>
>>>>> --b.
>>>>
>>>> I hit the same problem...
>>>>
>>>> Try removing /usr/lib/modprobe.d/nfs.conf (assuming you're running
>>>> Fedora).
>>>
>>> Oog, right.
>>>
>>> But, without testing--won't that make v4 mounts fail on older kernels?
>>
>> Actually, now that I look, this does not seem to break on older kernels
>> as long as you use a syntax like:
>>
>>     # mount -t nfs server:/export /mnt/point -o vers=4
>>
>> ...if, however you use a syntax like:
>>
>>     # mount -t nfs4 server:/export /mnt/point
>>
>> ...then it fails without the above file in place. I guess the question
>> we have to answer is: Do we want to continue to support the "-t nfs4"
>> mount syntax?
> 
> I think you're right that we want to deprecate it.
> 
> Though this is a bit of a harsh way to do it--would have been nice to
> have some transition period with a warning or something.

I didn't expect this to be broken, both ways of mounting still work on my VMs so I expected them to work for everybody else too.

- Bryan

> 
> --b.
> 

