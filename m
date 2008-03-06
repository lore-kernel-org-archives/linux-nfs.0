From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Last call for nfs-utils patches
Date: Thu, 06 Mar 2008 09:23:41 -0500
Message-ID: <47CFFE6D.3050507@RedHat.com>
References: <47CD680B.1070106@RedHat.com> <alpine.OSF.0.99.0803060931390.100983@replicant.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Timo Aaltonen <tjaalton-kf+aQKke1yb1KXRcyAk9cg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45872 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752162AbYCFOXt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Mar 2008 09:23:49 -0500
In-Reply-To: <alpine.OSF.0.99.0803060931390.100983-r6D5HDKEOC1C46yoE1Qrng@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Timo Aaltonen wrote:
> On Tue, 4 Mar 2008, Steve Dickson wrote:
> 
>>
>> I'm planning on cutting a nfs-utils-1.1.2 release since
>> there has been a number commits since the last 1.1.1 release.
>>
>> The attached list are all of the commits that have been made to
>> the git://linux-nfs.org/nfs-utils git tree.
>>
>> (Note: to get a working copy of this tree use:
>>    git clone  git://linux-nfs.org/nfs-utils nfs-utils)
>>
>> So if you don't see a commit you have posted to either
>> the nfs or nfsv4 mailing list it probably means I missed it
>> so you might want to bring it to my attention.
>> (Please Note, the patch authors in some of my earlier
>> commit are incorrect. This was simply due to my lack
>> of git knowledge. Once it was pointed it out to me,
>> the problem was corrected.)
>>
>> Also if you were holding off posting some (hopefully)
>> non-intrusive patches now it the time. There is a very
>> good chance I will not cut the release until this weekend.
> 
> What about the changes which make rpc.gssd spam the syslog less, ie.
> lowering the priority of two printerr's? It did the trick wonderfully,
> no more syslog overflows when user creds have expired.
Which patches are you referring to? It appears I missed them...

steved.

