Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:51221 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750844AbbEAVt2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 May 2015 17:49:28 -0400
From: ebiederm@xmission.com (Eric W. Biederman)
To: Hans de Bruin <jmdebruin@xmsnet.nl>
Cc: "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
References: <543ED24D.4070905@xmsnet.nl> <5443F5A1.1050004@xmsnet.nl>
	<544A7933.3010702@xmsnet.nl> <544A7D5C.5060804@xmsnet.nl>
	<871tpx1gcx.fsf@x220.int.ebiederm.org> <544B7D9F.1070403@xmsnet.nl>
	<87k33ow65k.fsf@x220.int.ebiederm.org> <544C1E40.6070901@xmsnet.nl>
	<87pp6kewzd.fsf@x220.int.ebiederm.org> <55436640.8080708@xmsnet.nl>
Date: Fri, 01 May 2015 16:45:03 -0500
In-Reply-To: <55436640.8080708@xmsnet.nl> (Hans de Bruin's message of "Fri, 01
	May 2015 13:40:48 +0200")
Message-ID: <87egn0as68.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: 3.17.0+ files disappearing after playing old dos game on nfsroot laptop
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hans de Bruin <jmdebruin@xmsnet.nl> writes:

> On 05/01/2015 06:35 AM, Eric W. Biederman wrote:
>> Hans de Bruin <jmdebruin@xmsnet.nl> writes:
>>
>>>> I expect what needs to happen is to confirm that nfs directory entry
>>>> revalidation is buggy, and at least for the short term re-add the nfs
>>>> logic that will avoid dropping a dentry if it is a mount point, or
>>>> path to a mount point, to avoid the nfs bugs.
>>>>
>>>
>>> ok, I will go in waiting mode.
>>
>> I dropped the ball on this but it looks like someone else hit the
>> problem and the following two commits fixed this issue:
>>
>> Can you confirm that things are working again?
>
> I noticed the issue was gone in one of the previous releases. I was
> wondering whether you changed something or not. Sorry for not
> notifying you.

No problem, and thank you for confirming the regression is fixed.
One more thing I can now mark off my list.

Eric

