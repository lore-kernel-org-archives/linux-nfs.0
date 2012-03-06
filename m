Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:32420 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932593Ab2CFAxY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 19:53:24 -0500
Message-ID: <4F556007.2030603@RedHat.com>
Date: Mon, 05 Mar 2012 19:53:27 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] umount.nfs: normalize path names during umounts.
References: <1330976165-19849-1-git-send-email-steved@redhat.com>  <1330976165-19849-2-git-send-email-steved@redhat.com>  <20120305212015.GA21904@us.ibm.com> <4F5559EA.7010206@RedHat.com> <1330993903.5407.3.camel@lade.trondhjem.org>
In-Reply-To: <1330993903.5407.3.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/05/2012 07:31 PM, Myklebust, Trond wrote:
> On Mon, 2012-03-05 at 19:27 -0500, Steve Dickson wrote:
>>
>> On 03/05/2012 04:20 PM, Malahal Naineni wrote:
>>> Steve Dickson [steved@redhat.com] wrote:
>>>
>>> Also, when you normalize, why not go the extra mile of doing it all the
>>> way as the patch I posted? I wanted to cover specs like
>>> "host:/server/../home/./blah". This patch only does partial
>>> normalization. The original patch also normalizes /proc/mount entry's
>>> pathname (this avoids dealing with trailing '/' hack that exists now).
>> I just do not see the need for that type of complexity... Maybe I'm
>> being a bit naive, but I see two problems here. One, v4 mounts 
>> with multiple slashes and two v4 mounts without any slashes... 
>>
>> Now both of our patches do address those issues but mine only
>> addresses those issues and no, it does not go the "extra mile" 
>> of addressing '..' in path names, but does it need to? Is 
>> there really an use case where people export things with ".."
>> in the path? 
>>
>> Sometimes going the just extra mile just brings more pain... 
>> for no reason... and believe me I'm no runner...  8-) 
> 
> Note that the NFSv4 server may have symlinks and/or referrals in the
> mount path, in which case it is game over for this kind of approach
> anyway: you can't 'normalise' your way to interpreting that...
Well I guess we will cross that bridge when we get there... At
this point I just want fixes these two bugs and move on... 

> 
> Is there any reason why we actually care about checking the crap
> in /etc/mtab on umount?
> 
Yeah... its called backwards compatibility with older distros...
Believe, if I could bury mtab I would... in a New York minute! 
I just don't see it happening... 

steved.
