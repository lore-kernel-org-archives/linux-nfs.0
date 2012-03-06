Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:1025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758066Ab2CFBe6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 20:34:58 -0500
Message-ID: <4F5569C5.1000100@RedHat.com>
Date: Mon, 05 Mar 2012 20:35:01 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] umount.nfs: normalize path names during umounts.
References: <1330976165-19849-1-git-send-email-steved@redhat.com>   <1330976165-19849-2-git-send-email-steved@redhat.com>   <20120305212015.GA21904@us.ibm.com> <4F5559EA.7010206@RedHat.com>  <1330993903.5407.3.camel@lade.trondhjem.org> <4F556007.2030603@RedHat.com> <1330995896.5407.8.camel@lade.trondhjem.org>
In-Reply-To: <1330995896.5407.8.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/05/2012 08:04 PM, Myklebust, Trond wrote:
>>> Is there any reason why we actually care about checking the crap
>>> in /etc/mtab on umount?
>>>
>> Yeah... its called backwards compatibility with older distros...
>> Believe, if I could bury mtab I would... in a New York minute! 
>> I just don't see it happening... 
> 
> Yes, but despite all your work, you are just replacing one broken model
> by another.
>
> 
> At least with the current code, they can _see_ that the model is broken
> and have an immediate incentive to move to the
> mtab-is-a-symlink-to-/proc/mounts based model. The latter is in any case
> the only one that is valid in the mount-namespace based world in which
> we've been living for the past 5 years or so...
> 
I do not disagree with what you are saying... The fact the code/model
is broken is unarguably true... Relying on info in the mtab verses 
/proc/mounts is completely brain dead... But those bits are on the 
street and need to be fixed... So the question is how to fix
them...

Sending out a patch that symbolically links mtab to /proc/mounts
would solve this entire problem! But I just can't make major change
like that in established worlds... Who know what people use mtab
for... I certainly don't. Changing mtab to read-only is recipe for
disaster... IMHO... 

Now if we don't want to take a patch like this in upstream 
that's a different story... This patch is basically meaningless 
when  it comes to new Linux distros... I'm ok with that..
But I do think its wise for us to at least try to be somewhat
backwards compatible....

steved.
 

