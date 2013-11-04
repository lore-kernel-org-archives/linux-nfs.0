Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:44684 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750789Ab3KDPc5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Nov 2013 10:32:57 -0500
Message-ID: <5277BE5E.4060406@RedHat.com>
Date: Mon, 04 Nov 2013 10:33:50 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: Tony Asleson <tasleson@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] exportfs: Return non-zero exit value on error
References: <1380756584-13335-1-git-send-email-tasleson@redhat.com> <52663791.6020605@RedHat.com> <52663908.1090708@RedHat.com> <20131029093547.1e6bff94@notabene.brown>
In-Reply-To: <20131029093547.1e6bff94@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 28/10/13 18:35, NeilBrown wrote:
> On Tue, 22 Oct 2013 04:36:24 -0400 Steve Dickson <SteveD@redhat.com> wrote:
> 
>>
>>
>> On 22/10/13 04:30, Steve Dickson wrote:
>>>
>>>
>>> On 02/10/13 19:29, Tony Asleson wrote:
>>>> To improve error handling when scripting exportfs it's useful
>>>> to have non-zero exit codes when the requested operation did not
>>>> succeed.
>>>>
>>>> This patch also returns a non-zero exit code if you request to
>>>> unexport a non-existant share.
>>>>
>>>> Signed-off-by: Tony Asleson <tasleson@redhat.com>
>>> Committed! 
>> Unfortunately I did not see Neil's patch before I committed this patch....
>> So I'm going to revert this patch in favor of Neil's... 
>>
>> steved.
> 
> Hi Steve,
> 
> it doesn't look like you achieved the result you were after.
> 
> commit 956aeff2e24304e938846f81f4b9db34cbf18a32
> is Tony's original patch.
> commit efe3c8d6cb4fc35909a64c0535087676a189fa5f
> reverts it.
> 
> commit 232eb7ad09f9fd2ae4918699f850e4f8cadc2632
> apples Tony's original patch again, but is credited
> to me with my patch description.
> 
> So something is a bit messed up.
> That is why my subsequent
>        exportfs: report failure if asked to unexport something not exported.
> 
> didn't apply.
Yea... I had a tough week last week... Let me sort this out and do the right
thing... 

steved.

> 
> NeilBrown
> 
