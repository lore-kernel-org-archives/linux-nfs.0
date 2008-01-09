From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 2/2] Fix lockd panic
Date: Wed, 09 Jan 2008 18:33:25 -0500
Message-ID: <478559C5.5020608@redhat.com>
References: <4781BE72.7050404@redhat.com>
	<18307.2757.579354.785142@notabene.brown>
	<47843957.9060208@redhat.com> <478450EA.7030608@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: cluster-devel@redhat.com, NFS list <linux-nfs@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
Return-path: <cluster-devel-bounces@redhat.com>
In-Reply-To: <478450EA.7030608@redhat.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/cluster-devel>
List-Post: <mailto:cluster-devel@redhat.com>
List-Help: <mailto:cluster-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=subscribe>
Sender: cluster-devel-bounces@redhat.com
Errors-To: cluster-devel-bounces@redhat.com
List-ID: <linux-nfs.vger.kernel.org>

Wendy Cheng wrote:
> Wendy Cheng wrote:
>
>> Neil Brown wrote:
>>
>>> Some options:
>>>
>>> Have an initial patch which removes all references to f_locks and
>>> includes the change in this patch. With that in place your main
>>> patch won't introduce a bug. If you do this, you should attempt to
>>> understand and justify the performance impact (does nlm_traverse_files
>>> become quadratic in number of locks. Is that acceptable?).
>>>
>>> Change the first patch to explicitly update f_count if you bypass the
>>> call to nlm_inspect_file.
>>>
>>> something else???
>>>
>>>
>>
>> Let's see what hch says in another email... will come back to this soon.
>>
>
> Will do a quick and dirty performance measure tomorrow when I get to 
> the office. Then we'll go from there.

The test didn't go well and I'm still debugging .. However, let's 
revisit the issue:

[quot from Neil's comment]
The important difference between the old code and the new code here is
that the old code tests "file->f_locks" while the new code iterates
through i_flock to see if there are any lockd locks.

f_locks is set to a count of lockd locks in nlm_traverse_locks which
*was* always called by nlm_inspect_file which is called immediately
before the code you are changing.
But since your patch, nlm_inspect_file does not always call
nlm_traverse_locks, so there is a chance that f_locks is wrong.

With this patch, f_locks it not used at all any more.
[end quot]

The point here is "with this patch, f_locks it not used at all any 
more." Note that we have a nice inline function "nlm_file_inuse", why 
should we use f_locks (that I assume people agree that it is awkward) ? 
Could we simply drop f_locks all together in this section of code?

-- Wendy
