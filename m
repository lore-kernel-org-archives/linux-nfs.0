Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55676 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753752Ab2KZPSA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 10:18:00 -0500
Message-ID: <50B38826.3030902@netapp.com>
Date: Mon, 26 Nov 2012 10:17:58 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 00/10] NFSD: Improve fault injection
References: <1351630254-26166-1-git-send-email-bjschuma@netapp.com> <20121114224846.GE539@fieldses.org> <50A5025C.8070201@netapp.com> <20121115150036.GG539@fieldses.org>
In-Reply-To: <20121115150036.GG539@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/15/2012 10:00 AM, J. Bruce Fields wrote:
> On Thu, Nov 15, 2012 at 09:55:24AM -0500, Bryan Schumaker wrote:
>> On 11/14/2012 05:48 PM, J. Bruce Fields wrote:
>>> On Tue, Oct 30, 2012 at 04:50:44PM -0400, bjschuma@netapp.com wrote:
>>>> From: Bryan Schumaker <bjschuma@netapp.com>
>>>>
>>>> While working on p2p-nfs, I discovered that I sometimes need to clear
>>>> state for a specific client to test all possible error recovery conditions.
>>>> The current fault injection code deletes state as it find it, so it can
>>>> be difficult to guess which state will be forgotten.  In addition, I
>>>> currently print out the amount of state forgotten but I don't give details
>>>> like "Forgot 3 locks from client w.x.y.z".  These patches set out to
>>>> improve that.
>>>>
>>>> The first 7 patches clean up the current code and prepare it for specific
>>>> client state removal.  Patch 8 adds prints information to the server's logs
>>>> when a fault injection file is read (such as "Client w.x.y.z has 3 open
>>>> files").  Patch 9 adds in a custom file operations structure so users can
>>>> write strings to fault injection files in addition to u64s.  Finally, patch
>>>> 10 allows users to remove state by writing a client's IP address to one of
>>>> the files.
>>>
>>> Apologies for putting you off again, but: I'd like to get Stanislav's
>>> patches sorted out first.  I think that shouldn't take too long--bug me
>>> in another week or so if I haven't come back to these by then.  These
>>> may need a little rebasing at that point.
>>
>> Ok, I'll add "bug Bruce" to my calendar... I took a quick glance through his patches and I don't think rebasing will be too hard.
> 
> Good, thanks!

So what's the plan for these patches?

- Bryan
> 
> --b.
> 

