From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] lockd: fix race in nlm_release()
Date: Thu, 21 Feb 2008 09:39:20 -0500
Message-ID: <47BD8D18.1000409@redhat.com>
References: <20080220191153.GG30160@fieldses.org> <1203535466.15034.5.camel@heimdal.trondhjem.org> <20080220192759.GI30160@fieldses.org> <1203536918.15034.11.camel@heimdal.trondhjem.org> <20080220234625.GN30160@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40374 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752396AbYBUOja (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2008 09:39:30 -0500
In-Reply-To: <20080220234625.GN30160@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Wed, Feb 20, 2008 at 02:48:38PM -0500, Trond Myklebust wrote:
>   
>> On Wed, 2008-02-20 at 14:27 -0500, J. Bruce Fields wrote:
>>     
>>> On Wed, Feb 20, 2008 at 02:24:26PM -0500, Trond Myklebust wrote:
>>>       
>>>> On Wed, 2008-02-20 at 14:11 -0500, J. Bruce Fields wrote:
>>>>         
>>>>> From: J. Bruce Fields <bfields@citi.umich.edu>
>>>>>
>>>>> The sm_count is decremented to zero but left on the nsm_handles list.
>>>>> So in the space between decrementing sm_count and acquiring nsm_mutex,
>>>>> it is possible for another task to find this nsm_handle, increment the
>>>>> use count and then enter nsm_release itself.
>>>>>
>>>>> Thus there's nothing to prevent the nsm being freed before we acquire
>>>>> nsm_mutex here.
>>>>>
>>>>> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>>>>> ---
>>>>>  fs/lockd/host.c |   10 ++++------
>>>>>  1 files changed, 4 insertions(+), 6 deletions(-)
>>>>>
>>>>> Am I missing something here?--b.
>>>>>
>>>>> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
>>>>> index c3f1194..960911c 100644
>>>>> --- a/fs/lockd/host.c
>>>>> +++ b/fs/lockd/host.c
>>>>>           
> ...
>   
>>> If you've got any other suggestions while I'm in the general area, I'm
>>> all ears.
>>>       
>> Just the usual plea to replace the host->h_server flag with 2 separate
>> lists: one list of client nlm_hosts, and one list of server
>> nlm_hosts :-)
>>     
>
> OK, I'm looking at that.
>
>   
>> ...Oh and a minor optimisation: If we're using a loopback mount, I don't
>> think we'll ever need to monitor 'localhost' :-)
>>     
>
> I assumed one of the only uses for loopback mounts was for testing and
> development, in which case it's better to keep the loopback behavior
> similar to non-loopback behavior, even if it's a little silly.  No?

We have encountered a number of customers, who are trying to deploy
in a cluster architecture, who mount over loopback.  We have tried
to convince them that this is a bad idea and/or that they should use
something like bind mounts instead, but they insist.

We try not to look too surprised when they encounter issues...  :-)

       ps
