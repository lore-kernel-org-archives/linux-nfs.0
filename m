Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:54167 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933216Ab2JCSY2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Oct 2012 14:24:28 -0400
Message-ID: <506C82DB.7020408@netapp.com>
Date: Wed, 03 Oct 2012 14:24:27 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/10] NFSD: Improve fault injection
References: <1347912979-20603-1-git-send-email-bjschuma@netapp.com> <506C7A1A.5000001@netapp.com> <20121003182325.GA28505@fieldses.org>
In-Reply-To: <20121003182325.GA28505@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/03/2012 02:23 PM, J. Bruce Fields wrote:
> On Wed, Oct 03, 2012 at 01:47:06PM -0400, Bryan Schumaker wrote:
>> Bruce, have you had a chance to look at these yet?  I don't see them in your git tree...
> 
> Sorry, no, it hasn't been a high priority.
> 
> I'll try to take a look soon.  They may end up being queued up for 3.8.

Sure, I was just making sure they don't get lost :).

- Bryan
> 
> --b.
> 
>>
>> - Bryan
>>
>> On 09/17/2012 04:16 PM, bjschuma@netapp.com wrote:
>>> From: Bryan Schumaker <bjschuma@netapp.com>
>>>
>>> While working on p2p-nfs, I discovered that I sometimes need to clear
>>> state for a specific client to test all possible error recovery conditions.
>>> The current fault injection code deletes state as it find it, so it can
>>> be difficult to guess which state will be forgotten.  In addition, I
>>> currently print out the amount of state forgotten but I don't give details
>>> like "Forgot 3 locks from client w.x.y.z".  These patches set out to
>>> improve that.
>>>
>>> The first 7 patches clean up the current code and prepare it for specific
>>> client state removal.  Patch 8 adds prints information to the server's logs
>>> when a fault injection file is read (such as "Client w.x.y.z has 3 open
>>> files").  Patch 9 adds in a custom file operations structure so users can
>>> write strings to fault injection files in addition to u64s.  Finally, patch
>>> 10 allows users to remove state by writing a client's IP address to one of
>>> the files.
>>>
>>> Questions, comments and suggestions are appreciated!
>>>
>>> - Bryan
>>>
>>> Bryan Schumaker (10):
>>>   NFSD: Fold fault_inject.h into state.h
>>>   NFSD: Lock state before calling fault injection function
>>>   NFSD: Clean up forgetting clients
>>>   NFSD: Clean up forgetting locks
>>>   NFSD: Clean up forgetting openowners
>>>   NFSD: Clean up forgetting and recalling delegations
>>>   NFSD: Fault injection operations take a per-client forget function
>>>   NFSD: Reading a fault injection file prints a state count
>>>   NFSD: Add a custom file operations structure for fault injection
>>>   NFSD: Forget state for a specific client
>>>
>>>  fs/nfsd/fault_inject.c | 108 ++++++++++++++++++++++++-----
>>>  fs/nfsd/fault_inject.h |  28 --------
>>>  fs/nfsd/nfs4state.c    | 182 +++++++++++++++++++++++++++++++------------------
>>>  fs/nfsd/nfsctl.c       |   2 +-
>>>  fs/nfsd/state.h        |  23 +++++++
>>>  5 files changed, 230 insertions(+), 113 deletions(-)
>>>  delete mode 100644 fs/nfsd/fault_inject.h
>>>
>>

