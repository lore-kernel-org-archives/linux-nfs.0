Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-3.concepts.nl ([213.197.30.127]:60159 "EHLO
	smtp-3.concepts.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643AbbEAL4T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 May 2015 07:56:19 -0400
Message-ID: <55436640.8080708@xmsnet.nl>
Date: Fri, 01 May 2015 13:40:48 +0200
From: Hans de Bruin <jmdebruin@xmsnet.nl>
MIME-Version: 1.0
To: "Eric W. Biederman" <ebiederm@xmission.com>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
Subject: Re: 3.17.0+ files disappearing after playing old dos game on nfsroot
 laptop
References: <543ED24D.4070905@xmsnet.nl> <5443F5A1.1050004@xmsnet.nl>	<544A7933.3010702@xmsnet.nl> <544A7D5C.5060804@xmsnet.nl>	<871tpx1gcx.fsf@x220.int.ebiederm.org> <544B7D9F.1070403@xmsnet.nl>	<87k33ow65k.fsf@x220.int.ebiederm.org> <544C1E40.6070901@xmsnet.nl> <87pp6kewzd.fsf@x220.int.ebiederm.org>
In-Reply-To: <87pp6kewzd.fsf@x220.int.ebiederm.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/01/2015 06:35 AM, Eric W. Biederman wrote:
> Hans de Bruin <jmdebruin@xmsnet.nl> writes:
>
>>> I expect what needs to happen is to confirm that nfs directory entry
>>> revalidation is buggy, and at least for the short term re-add the nfs
>>> logic that will avoid dropping a dentry if it is a mount point, or
>>> path to a mount point, to avoid the nfs bugs.
>>>
>>
>> ok, I will go in waiting mode.
>
> I dropped the ball on this but it looks like someone else hit the
> problem and the following two commits fixed this issue:
>
> Can you confirm that things are working again?

I noticed the issue was gone in one of the previous releases. I was 
wondering whether you changed something or not. Sorry for not notifying you.

-- 
Hans

