Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:16515 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750759Ab1JUSZr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Oct 2011 14:25:47 -0400
Message-ID: <4EA1B919.5060801@netapp.com>
Date: Fri, 21 Oct 2011 14:25:29 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: fix for open leaks, for 3.2
References: <1318888557-14719-1-git-send-email-bfields@redhat.com> <20111017215741.GE13368@fieldses.org> <4E9CA591.8050708@netapp.com>
In-Reply-To: <4E9CA591.8050708@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/17/2011 06:00 PM, Bryan Schumaker wrote:
> On 10/17/2011 05:57 PM, J. Bruce Fields wrote:
>> On Mon, Oct 17, 2011 at 05:55:49PM -0400, J. Bruce Fields wrote:
>>> Bryan Schumaker noticed that we have a longstanding leak of an open
>>> owner each time the first open with a new open owner fails.
>>>
>>> The following patches fix that, along with a few other less likely leaks
>>> that occur if a memory allocation fails after a file is created.
>>
>> By the way, Bryan, I didn't try to write a real test case for that
>> leak--would it be easy for you to rerun the test you were running before
>> and verify whether it's gone?
> 
> Sure, no problem.  I'll let you know what I find.

Looks like these patches worked.  I never deleted more than one client structure during my test.

- Bryan
> 
> - Bryan
>>
>> --b.
>>
>>>
>>> I intend to commit these to for-3.2.  Any review welcomed.
>>>
>>> --b.
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

