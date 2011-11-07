Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43003 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932713Ab1KGQVT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Nov 2011 11:21:19 -0500
Received: by faan17 with SMTP id n17so159017faa.19
        for <linux-nfs@vger.kernel.org>; Mon, 07 Nov 2011 08:21:18 -0800 (PST)
Message-ID: <4EB80576.4080301@tonian.com>
Date: Mon, 07 Nov 2011 18:21:10 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: nfsd (and lock) changes for 3.2
References: <20111025121924.GA15662@fieldses.org> <4EA77B78.6080706@panasas.com> <20111027203412.GB31669@fieldses.org> <4EA9F5E8.6060900@panasas.com> <20111028144252.GB5798@fieldses.org> <20111104160439.GA32756@fieldses.org> <4EB417C8.4000502@panasas.com>
In-Reply-To: <4EB417C8.4000502@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-11-04 18:50, Boaz Harrosh wrote:
> On 11/04/2011 09:04 AM, J. Bruce Fields wrote:
>> Boaz points out that I forgot to add stable cc's to two commits:
>>
>> 	48483bf23a568f3ef4cc7ad2c8f1a082f10ad0e7 "nfsd4: simplify recovery dir setting"
>> 	6577aac01f00636c16cd583c30bd4dedf18475d5 "nfsd4: fix failure to
>> 	end nfsd4 grace period"
>>
>> which fix a regression introduced by
>> ab1350b2b3c1dd2e465a6abdda608d8c44facfb8 "nfsd41: Deny new lock before
>> RECLAIM_COMPLETE done" (first included in v3.1-rc1).
>>
>> Included below for reference, but I assume simplest for you will be to
>> cherry-pick the above two sha1's.
>>
>> Thanks!
>>
>> --b.
>>
> 
> Bruce hi, thanks
> 
> Yesterday I hit this bug again. I rebased on Benny's tree which did not have them
> for some reason. It's hunting me. ;-)

That's odd.  What tip did you use?  These patches should be there:
8474c1e95786608a79849070b34f93924fcad087
530b7be2fbd79a8758230d53fc5f050d5c1561ba

Benny

> 
> Just for Future reference, these patches were suppose to be submitted very early around
> rc3 when we found them. This is what the -rcX are for, to test and fix what was broken
> in the merge window.
> 
> Please forgive me I should have followed it through, but was too busy and forgot.
> 
> But in general you should always have an rc-fixes branch and bug fixes patches
> should go there and not into the linux-next branch. And yes both branches should
> be included in linux-next.
> 
> This way there is nothing to forget
> 
> Thanks
> Boaz
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
