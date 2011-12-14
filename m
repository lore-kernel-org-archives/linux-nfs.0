Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:44084 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751047Ab1LNOeC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Dec 2011 09:34:02 -0500
Message-ID: <4EE8B3C9.8070800@netapp.com>
Date: Wed, 14 Dec 2011 09:33:45 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: Only reinitilize the recall_lru list under the
 recall lock
References: <1323812158-5183-1-git-send-email-bjschuma@netapp.com> <20111213221209.GA30904@fieldses.org> <4EE8A7BA.6050406@netapp.com> <20111214140744.GA4322@fieldses.org>
In-Reply-To: <20111214140744.GA4322@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed Dec 14 09:07:44 2011, J. Bruce Fields wrote:
> On Wed, Dec 14, 2011 at 08:42:18AM -0500, Bryan Schumaker wrote:
>> On Tue Dec 13 17:12:09 2011, J. Bruce Fields wrote:
>>> On Tue, Dec 13, 2011 at 04:35:58PM -0500, bjschuma@netapp.com wrote:
>>>> From: Bryan Schumaker <bjschuma@netapp.com>
>>>>
>>>> unhash_delegation() will grab the recall lock before calling
>>>> list_del_init() in each of these places.  This patch removes the
>>>> redundant calls.
>>>
>>> Looks right, thanks.  (How did you happen across this?)
>>
>> I was looking over the fault injection stuff to see if I can figure out 
>> where an occasional oops was coming from.  It seems to happen when I 
>> forget delegations, so I was looking at how other functions release 
>> delegations to see if there was something I missed.  The oops doesn't 
>> happen often enough for me to know if this patch fixes it yet, though.
>
> Hm, OK.  Could you post the oops?

I don't see it in the logs on the server, but I'll keep looking.  I'll 
post it the next time I come across it.

- Bryan
>
> --b.


