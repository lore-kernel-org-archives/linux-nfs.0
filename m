Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:23133 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756320Ab0EZInL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 May 2010 04:43:11 -0400
Message-ID: <4BFCDF1B.60608@panasas.com>
Date: Wed, 26 May 2010 11:43:07 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Dean Hildebrand <seattleplus@gmail.com>
CC: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/22] LAYOUTGET invocation
References: <1273972993-15369-1-git-send-email-iisaman@netapp.com> <4BFC1686.4000509@gmail.com> <51AD8F7D-D172-4DE6-8F7A-CDFA292CBF8B@netapp.com> <4BFC2FA2.2050506@gmail.com>
In-Reply-To: <4BFC2FA2.2050506@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/25/2010 11:14 PM, Dean Hildebrand wrote:
> 
> 
>>
>> I can send some post_submit patches with the code ifdef'ed out if people would be content with that.
>>   
> 
> Thanks for the background.  I would be much happier if you sent patches 
> with the code ifdef'd out, added with the comment in the code regarding 
> which patches you believe introduced the problem.
> 
> Dean
>> Fred

I disagree. Source code is not a version management system. We have git
for that. The code is never lost it is there for eternity in the git
tree. We could ask Benny to tag the last branch that had broken directIO
as LAST_directIO_VERSION for easy random access at future time.

If in the future someone smart wants to forward port the code and fix it
then the *right* way to do it is by manual octopus merge at the point of
branch.
Never, Never uncomment out code that was sitting collecting dust.
Manual octopus merge I mean using the two diffs from the two sides of the
branch, and replaying one on the other. For instance if at one patch
a function was moved, then redo the move of the current function again, not
leave the old code as it was before. Let the merge point out the points of
friction. Because you see, with commented code, there is never a merge
conflict it will always uncomment.

And anyway the Kernel people will never accept code in comments. There
are out-of-tree gits to do that. So I don't even think it is an option.
The pnfs branches are patches that should eventually go upstream. Or
are currently the only option for the testing of upstream code.

Boaz
