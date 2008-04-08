From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NLM: hold BKL when clearing global lockd task and serv
	vars
Date: Tue, 8 Apr 2008 16:08:40 -0400
Message-ID: <3B9C3AE1-2C48-49D7-A961-51AE72A685D1@oracle.com>
References: <1207575514-6703-1-git-send-email-jlayton@redhat.com>
	<1207575514-6703-2-git-send-email-jlayton@redhat.com>
	<20080407164500.GA17728@infradead.org>
	<20080407175615.GD3305@fieldses.org>
	<20080407162241.0a06fd6f@tleilax.poochiereds.net>
	<20080407205027.GE11219@fieldses.org>
	<20080408092102.2404f5ee@tleilax.poochiereds.net>
	<20080408162821.GA8994@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20080408162821.GA8994@fieldses.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 8, 2008, at 12:28 PM, J. Bruce Fields wrote:
> On Tue, Apr 08, 2008 at 09:21:02AM -0400, Jeff Layton wrote:
>> On Mon, 7 Apr 2008 16:50:27 -0400
>> "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>
>>> On Mon, Apr 07, 2008 at 04:22:41PM -0400, Jeff Layton wrote:
>>>> On Mon, 7 Apr 2008 13:56:15 -0400
>>>> "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>>>
>>>>> On Mon, Apr 07, 2008 at 12:45:01PM -0400, Christoph Hellwig wrote:
>>>>>> On Mon, Apr 07, 2008 at 09:38:34AM -0400, Jeff Layton wrote:
>>>>>>> The global task and serv pointers for lockd are normally  
>>>>>>> protected by
>>>>>>> the nlmsvc_mutex. The exception is when the lockd exits  
>>>>>>> abnormally. When
>>>>>>> this occurs, these variables are cleared without any locking.
>>>>>>
>>>>>> Shouldn't we get rid of the case where it exits abnormally  
>>>>>> instead?
>>>>>
>>>>> I tried to figure out when this could actually occur (when can
>>>>> svc_recv() return an error other than -EINTR or -EAGAIN?), and  
>>>>> got lost
>>>>> in sock_recvmsg():
>>>>>
>>>>> 	- svc_recv() itself returns only -EAGAIN or the return from
>>>>> 	  ->xpo_recvfrom().
>>>>> 	- the only xpo_recvfrom() that's interesting is
>>>>> 	  svc_tcp_recvfrom(), which can return the error it gets from
>>>>> 	  svc_recvfrom(), which can return the error from
>>>>> 	  kernel_recvmsg(), which gets its return from sock_recvmsg().
>>>>>
>>>>> Since __sock_recvmsg() has a security hook, it looks like we  
>>>>> can end up
>>>>> with an -EACCES from selinux?
>>>>>
>>>>> So one case would be selinux deciding we weren't allowed to  
>>>>> receive
>>>>> packets from this socket.  Huh.
>>>>
>>>> I got lost there too, but I would suspect that there are other  
>>>> errors
>>>> that can bubble up from the lower networking layers as well.  
>>>> Even if
>>>> there aren't currently, it's probably still prudent to assume  
>>>> that it's
>>>> a possibility and code for it.
>>>>
>>>> I tend to think the safest thing is probably to do a long sleep  
>>>> (1s or
>>>> so and retry when we get an error (maybe also a ratelimited  
>>>> printk?).
>>>
>>> Yeah, I guess I can't think of anything better.
>>>
>>
>> Ok, I went ahead and did patches for this and gave them a quick test
>> this morning. Obviously, these are hard to fully unit test since this
>> seems to be a very uncommon occurrence.
>
> I suppose this could probably be reproduced with some selinux magic.
>
>> Any thoughts?
>
> If anyone does ever hit this and it doesn't go away, the printk (even
> with the ratelimiting) could be pretty annoying, so it might be worth
> arranging to print this just once.  But perhaps we can wait and see if
> that actually happens.


Coding by contract would be useful here.

If svc_recv() returns only specific error codes (and never anything  
else) then its callers don't need any special logic for  
"unrecognized" return codes.

Thus, ensuring that svc_recv() returns only EINTR, EACCES, or EAGAIN  
would limit the complexity and failure modes of its callers.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
