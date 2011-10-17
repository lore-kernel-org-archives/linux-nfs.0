Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21514 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752333Ab1JQWAc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Oct 2011 18:00:32 -0400
Message-ID: <4E9CA591.8050708@netapp.com>
Date: Mon, 17 Oct 2011 18:00:49 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: fix for open leaks, for 3.2
References: <1318888557-14719-1-git-send-email-bfields@redhat.com> <20111017215741.GE13368@fieldses.org>
In-Reply-To: <20111017215741.GE13368@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/17/2011 05:57 PM, J. Bruce Fields wrote:
> On Mon, Oct 17, 2011 at 05:55:49PM -0400, J. Bruce Fields wrote:
>> Bryan Schumaker noticed that we have a longstanding leak of an open
>> owner each time the first open with a new open owner fails.
>>
>> The following patches fix that, along with a few other less likely leaks
>> that occur if a memory allocation fails after a file is created.
> 
> By the way, Bryan, I didn't try to write a real test case for that
> leak--would it be easy for you to rerun the test you were running before
> and verify whether it's gone?

Sure, no problem.  I'll let you know what I find.

- Bryan
> 
> --b.
> 
>>
>> I intend to commit these to for-3.2.  Any review welcomed.
>>
>> --b.
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

