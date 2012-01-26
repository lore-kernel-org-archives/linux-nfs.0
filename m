Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:24362 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751720Ab2AZPbD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jan 2012 10:31:03 -0500
Message-ID: <4F2171B5.2030103@RedHat.com>
Date: Thu, 26 Jan 2012 10:31:01 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@poochiereds.net>
CC: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 09/11] nfsdcld: reopen pipe if it's deleted and recreated
References: <1327348931-785-1-git-send-email-jlayton@redhat.com>	<1327348931-785-10-git-send-email-jlayton@redhat.com>	<4F2046F8.80609@RedHat.com>	<20120125140954.5312a80f@tlielax.poochiereds.net>	<4F20587E.9070209@RedHat.com>	<20120125152814.391ae064@tlielax.poochiereds.net>	<4F207C7C.4090207@RedHat.com>	<20120125183206.5efcd845@corrin.poochiereds.net>	<4F214B77.8050300@RedHat.com>	<20120126082830.23324255@corrin.poochiereds.net> <20120126093059.5c732d75@corrin.poochiereds.net>
In-Reply-To: <20120126093059.5c732d75@corrin.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/26/2012 09:30 AM, Jeff Layton wrote:
> On Thu, 26 Jan 2012 08:28:30 -0500
> Jeff Layton <jlayton@redhat.com> wrote:
> 
>> On Thu, 26 Jan 2012 07:47:51 -0500
>> Steve Dickson <SteveD@redhat.com> wrote:
>>
>>>
>>>
>>> On 01/25/2012 06:32 PM, Jeff Layton wrote:
>>>> On Wed, 25 Jan 2012 17:04:44 -0500
>>>> Steve Dickson <SteveD@redhat.com> wrote:
>>>>
>>>>>
>>>>>
>>>>> On 01/25/2012 03:28 PM, Jeff Layton wrote:
>>>>>> On Wed, 25 Jan 2012 14:31:10 -0500
>>>>>> Steve Dickson <SteveD@redhat.com> wrote:
>>>>>>
>>>>>>>
>>>>>>>
>>>>>>> On 01/25/2012 02:09 PM, Jeff Layton wrote:
>>>>>>>> On Wed, 25 Jan 2012 13:16:24 -0500
>>>>>>>> Steve Dickson <SteveD@redhat.com> wrote:
>>>>>>>>
>>>>>>>>> Hey Jeff,
>>>>>>>>>
>>>>>>>>> Commit inline... 
>>>>>>>>>
>>>>>>>>> On 01/23/2012 03:02 PM, Jeff Layton wrote:
>>>>>>>>>> This can happen if nfsd is shut down and restarted. If that occurs,
>>>>>>>>>> then reopen the pipe so we're not waiting for data on the defunct
>>>>>>>>>> pipe.
>>>>>>>>>>
>>>>>>>>>> Signed-off-by: Jeff Layton <jlayton@redhat.com>
>>>>>>>>>> ---
>>>>>>>>>>  utils/nfsdcld/nfsdcld.c |   84 +++++++++++++++++++++++++++++++++++++++++-----
>>>>>>>>>>  1 files changed, 74 insertions(+), 10 deletions(-)
>>>>>>>>>>
>>>>>>>>>> diff --git a/utils/nfsdcld/nfsdcld.c b/utils/nfsdcld/nfsdcld.c
>>>>>>>>>> index b0c08e2..0dc5b37 100644
>>>>>>>>>> --- a/utils/nfsdcld/nfsdcld.c
>>>>>>>>>> +++ b/utils/nfsdcld/nfsdcld.c
>>>>>>>>>> @@ -57,6 +57,8 @@ struct cld_client {
>>>>>>>>>>  
>>>>>>>>>>  /* global variables */
>>>>>>>>>>  static char *pipepath = DEFAULT_CLD_PATH;
>>>>>>>>>> +static int 		inotify_fd = -1;
>>>>>>>>>> +static struct event	pipedir_event;
>>>>>>>>>>  
>>>>>>>>>>  static struct option longopts[] =
>>>>>>>>>>  {
>>>>>>>>>> @@ -68,8 +70,10 @@ static struct option longopts[] =
>>>>>>>>>>  	{ NULL, 0, 0, 0 },
>>>>>>>>>>  };
>>>>>>>>>>  
>>>>>>>>>> +
>>>>>>>>>>  /* forward declarations */
>>>>>>>>>>  static void cldcb(int UNUSED(fd), short which, void *data);
>>>>>>>>>> +static void cld_pipe_reopen(struct cld_client *clnt);
>>>>>>>>>>  
>>>>>>>>>>  static void
>>>>>>>>>>  usage(char *progname)
>>>>>>>>>> @@ -80,10 +84,62 @@ usage(char *progname)
>>>>>>>>>>  
>>>>>>>>>>  #define INOTIFY_EVENT_MAX (sizeof(struct inotify_event) + NAME_MAX)
>>>>>>>>>>  
>>>>>>>>>> +static void
>>>>>>>>>> +cld_inotify_cb(int UNUSED(fd), short which, void *data)
>>>>>>>>>> +{
>>>>>>>>>> +	int ret, oldfd;
>>>>>>>>>> +	char evbuf[INOTIFY_EVENT_MAX];
>>>>>>>>>> +	char *dirc = NULL, *pname;
>>>>>>>>>> +	struct inotify_event *event = (struct inotify_event *)evbuf;
>>>>>>>>>> +	struct cld_client *clnt = data;
>>>>>>>>>> +
>>>>>>>>>> +	if (which != EV_READ)
>>>>>>>>>> +		return;
>>>>>>>>>> +
>>>>>>>>>> +	dirc = strndup(pipepath, PATH_MAX);
>>>>>>>>>> +	if (!dirc) {
>>>>>>>>>> +		xlog_err("%s: unable to allocate memory", __func__);
>>>>>>>>>> +		goto out;
>>>>>>>>>> +	}
>>>>>>>>>> +
>>>>>>>>>> +	ret = read(inotify_fd, evbuf, INOTIFY_EVENT_MAX);
>>>>>>>>>> +	if (ret < 0) {
>>>>>>>>>> +		xlog_err("%s: read from inotify fd failed: %m", __func__);
>>>>>>>>>> +		goto out;
>>>>>>>>>> +	}
>>>>>>>>>> +
>>>>>>>>>> +	/* check to see if we have a filename in the evbuf */
>>>>>>>>>> +	if (!event->len)
>>>>>>>>>> +		goto out;
>>>>>>>>>> +
>>>>>>>>>> +	pname = basename(dirc);
>>>>>>>>>> +
>>>>>>>>>> +	/* does the filename match our pipe? */
>>>>>>>>>> +	if (strncmp(pname, event->name, event->len))
>>>>>>>>>> +		goto out;
>>>>>>>>>> +
>>>>>>>>>> +	/*
>>>>>>>>>> +	 * reopen the pipe. The old fd is not closed until the new one is
>>>>>>>>>> +	 * opened, so we know they should be different if the reopen is
>>>>>>>>>> +	 * successful.
>>>>>>>>>> +	 */
>>>>>>>>>> +	oldfd = clnt->cl_fd;
>>>>>>>>>> +	do {
>>>>>>>>>> +		cld_pipe_reopen(clnt);
>>>>>>>>>> +	} while (oldfd == clnt->cl_fd);
>>>>>>>>> Doesn't this have a potential for an infinite loop? 
>>>>>>>>>
>>>>>>>>> steved.  
>>>>>>>>
>>>>>>>>
>>>>>>>> Yes. If reopening the new pipe continually fails then it will loop
>>>>>>>> forever.
>>>>>>> Would it be more accurate to say it would be spinning forever? 
>>>>>>> Since there is no sleep or delay in cld_pipe_reopen, what's
>>>>>>> going to stop the daemon from spinning in a CPU bound loop?
>>>>>>>
>>>>>>
>>>>>> Well, not spinning in a userspace loop...it'll continually be cycling on
>>>>>> an open() call that's not working for whatever reason. We sort of have
>>>>>> to loop on that though. I think the best we can do is add a sleep(1) in
>>>>>> there or something. Would that be sufficient?
>>>>>>
>>>>> I still think it going to needlessly suck up CPU cycles... 
>>>>>
>>>>> The way I handled this in the rpc.idmapd daemon was to do the
>>>>> reopen on a SIGHUP signal. Then in NFS server initscript 
>>>>> I did the following:
>>>>>     /usr/bin/pkill -HUP rpc.idmapd
>>>>>
>>>>> Thoughts?
>>>>>
>>>>
>>>> Ugh, that requires manual intervention if the pipe is removed and
>>>> recreated. If someone restarts nfsd and doesn't send the signal, then
>>>> they won't get the upcalls. I'd prefer something that "just works".
>>> I have not seen any bz open saying rpc.idmapd doesn't just work... 
>>>
>>>>
>>>> Seriously, is it that big a deal to just loop here? One open(2) call
>>>> every second doesn't seem that bad, and honestly if a new pipe pops up
>>>> and the daemon can't open it then a few CPU cycles is the least of your
>>>> worries.
>>>>
>>> Put the daemon in that loop and then run the top command in another 
>>> window.. If the daemon is at the top of the list then it is a big
>>> deal because that daemon will on the top forever for no reason, in
>>> the cast of the NFS server not coming back. 
>>>
>>
>> This situation is really unlikely. The daemon does not reopen the pipe
>> when the old one goes away. It reopens it when a new one with the same
>> name is recreated in the directory.
>>
>> That's an important distinction because in order to get into this loop,
>> you'd need to:
>>
>> 1/ remove the old pipe -- this happens when the daemon is shut down
Just to be clear, when this happens, that while loop is *not* executed

>>
>> 2/ create a new pipe -- this happens when the daemon is restarted
Then when this happens that while loop is *not* executed.

>>
> 
> To clarify, the above happen when knfsd are stopped and started...
> 
>> 3/ not be able to open the new pipe for some reason, even though you
>> were able to open the old one
Only when 1,2,3 happens synchronously will that while loop be execute, correct?

More the to the point, stopping the server will *not* cause this while 
to be execute until the server is restarted, correct?

>>
>> The reason I put this in a loop is because it's possible (though not
>> likely) that you'd hit condition #3 temporarily. In that event, looping
>> and retrying an open(2) call every second seems entirely reasonable and
>> is more fault tolerant than just dying here. The open of a pipe takes
>> much less than 1s, so there's plenty of time between open attempts for
>> the machine to get other things done
By no means am I saying not to make it fault tolerant... Please do! I'm
just worried about the daemon spinning out of control.. :-)

>>
>> If it turns out that there's a problem, the admin can shut down the
>> daemon at that point. They may need to do so anyway in order to resolve
>> the situation if the thing preventing the opening of the pipe isn't
>> temporary.
I guess I would rather figure this out now, during the design, than
after the bits hit the street... 

steved.
