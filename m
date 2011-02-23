Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:37144 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751340Ab1BWD7e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Feb 2011 22:59:34 -0500
Message-ID: <4D64861F.5000707@parallels.com>
Date: Tue, 22 Feb 2011 21:59:27 -0600
From: Rob Landley <rlandley@parallels.com>
To: NeilBrown <neilb@suse.de>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: CACHE_NEW_EXPIRY is 120, nextcheck initialized to 30*60=1800?
References: <4D63BAA0.3090505@parallels.com> <20110223080731.6c013be2@notabene.brown>
In-Reply-To: <20110223080731.6c013be2@notabene.brown>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 02/22/2011 03:07 PM, NeilBrown wrote:
> On Tue, 22 Feb 2011 07:31:12 -0600 Rob Landley <rlandley@parallels.com> wrote:
> 
>> In net/sunrpc/cache.c line 416 or so (function cache_clean()) there's
>> this bit:
>>
>> else {
>>         current_index = 0;
>>         current_detail->nextcheck = seconds_since_boot()+30*60;
>> }
>>
>> The other uses of seconds_since_boot() add CACHE_NEW_EXPIRY (which is
>> 120).  This is A) more than ten times that, B) a magic inline constant.
>>
>> Is there a reason for this?  (Some subtle cache lifetime balancing thing?)
> 
> Apples and oranges are both fruit, but don't taste the same...

I know what "apples and oranges" means, thanks.

I'm trying to understand this code, and finding a lot of it hard to
figure out.  For example, in net/sunrpc/svcauth_unix.c there are two
instances of:

  expiry = get_expiry(&mesg);
  if (expiry ==0)
          return -EINVAL;

Except that get_expiry() defined in include/linux/sunrpc/cache.h returns
the difference between the int stored at &mesg and getboottime(), which
implies that the value can go negative fairly easily if the system is
busy with something else for a second, so comparing for equality with
zero seems odd if it's easy to _miss_.  Possibly some kind of timer is
scheduled to force this test to happen at the expiry time, but if so I
haven't found it yet...

(I'm trying to hunt down a specific bug where a cached value of some
kind is using the wrong struct net * context, and thus if I mount nfsv3
from the host context it works, and from a container it also works, but
if I have different (overlapping) network routings in host and container
and I mount the same IP from the host from the container it doesn't
work, even if I _unmount_ the host's copy before mounting the
container's copy (or vice versa).  But that it starts working again when
I give it a couple minutes after the umount for the cache data to time
out...)

Mostly I'm assuming you guys know what you're doing and that my
understanding of the enormous layers of nested cacheing is incomplete,
but there's a lot of complexity to dig through here...

Rob
