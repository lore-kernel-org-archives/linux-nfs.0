From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfsd: default to kernel default for minorversion 1
Date: Fri, 12 Feb 2010 16:44:03 -0500
Message-ID: <4B75CBA3.8010001@RedHat.com>
References: <1264631166-21898-1-git-send-email-bfields@citi.umich.edu> <1264631166-21898-2-git-send-email-bfields@citi.umich.edu> <20100201195821.GB19418@fieldses.org> <4B6B480C.1050307@RedHat.com> <20100205161001.GB24926@fieldses.org> <20100205192859.GE24926@fieldses.org> <20100205200501.GA28483@fieldses.org> <4B75B2DF.9060005@RedHat.com> <20100212200548.GB23361@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9457 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755179Ab0BLVoH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Feb 2010 16:44:07 -0500
In-Reply-To: <20100212200548.GB23361@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/12/2010 03:05 PM, J. Bruce Fields wrote:
> On Fri, Feb 12, 2010 at 02:58:23PM -0500, Steve Dickson wrote:
>>
>>
>> On 02/05/2010 03:05 PM, J. Bruce Fields wrote:
>>> From: J. Bruce Fields <bfields@citi.umich.edu>
>>>
>>> The current kernel code should not be enabled by default, because it
>>> does not yet attempt to be a conform completely to the rfc; for example,
>>> some required pieces of protocol are missing.
>>>
>>> Therefore the kernel defaults to leaving minorversion1 off.  When the
>>> code matures sufficiently, that default will change.
>>>
>>> That kernel default becomes meaningless if nfs-utils always explicitly
>>> turns 4.1 on or off.  So, nfs-utils should by default do nothing.
>>>
>>> Early adopters that want to turn on NFSv4.1 explicitly can still do so
>>> using
>>>
>>> 	echo "+4.1" >/proc/fs/nfsd/versions
>>>
>> When I write to /proc/fs/nfsd/versions I'm getting 
>>    write error: Device or resource busy
>>
>> What did you do to make the file writeable?
> 
> You just need to do it before starting nfsd.
Well before nfsd starts but after the nfsd module is loaded
(assuming nfsd is a module)

> 
> So if it's just a one-off experiment you could
> 
> 	/etc/init.d/nfs-server stop
> 	echo "+4.1" >/proc/fs/nsfd/versions
> 	/etc/init.d/nfs-server start
> 
> On machines where I was using 4.1 regularly I'd probably at a line to
> the init script, or to a local init script that ran before it.
Yea.. I'm looking into do something of this nature...

The odd thing about this patch is 4.1 can only be turned off. There
is no way to enabled except from doing the above echo... which 
seems to beg the question, why have the 4.1 code in nfsd at all?

steved.
 
