From: Olga Kornievskaia <aglo@citi.umich.edu>
Subject: Re: [PATCH] nfsd: use nfs client rpc callback program
Date: Fri, 19 Sep 2008 15:51:04 -0400
Message-ID: <48D402A8.7020006@citi.umich.edu>
References: <48D15DF0.4000406@panasas.com> <20080917231018.GA5723@fieldses.org> <48D193EE.2020805@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, pnfs mailing list <pnfs@linux-nfs.org>,
	Fred Isaman <iisaman@citi.umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:27381 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752176AbYISUX4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Sep 2008 16:23:56 -0400
In-Reply-To: <48D193EE.2020805@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Benny Halevy wrote:
> On Sep. 17, 2008, 18:10 -0500, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>   
>> On Wed, Sep 17, 2008 at 02:43:44PM -0500, Benny Halevy wrote:
>>     
>>> From: Benny Halevy <bhalevy@panasas.com>
>>>
>>> since commit ff7d9756b501744540be65e172d27ee321d86103
>>> "nfsd: use static memory for callback program and stats"
>>> do_probe_callback uses a static callback program
>>> (NFS4_CALLBACK) rather than the one set in clp->cl_callback.cb_prog
>>> as passed in by the client in setclientid (4.0)
>>> or create_session (4.1).
>>>       
>> Ugh, yes, sorry about that.  (I wonder why pynfs testing didn't catch
>> this?  Oh, I guess it's because NFS4_CALLBACK is the program number our
>> client always gives us.)
>>     
>
> Well, Fred (thanks!) added a test today which uses a non-default
> callback program and he sees a corresponding callback coming back.
>
> (Note that this test is not absolutely generic as the server is
> not required to probe the callback immediately, or at all, after
> setclientid or create_session.)
>
>   
>>> @@ -371,6 +356,8 @@ static int do_probe_callback(void *data)
>>>  		.to_maxval	= (NFSD_LEASE_TIME/2) * HZ,
>>>  		.to_exponential	= 1,
>>>  	};
>>> +	static struct rpc_stat	cb_stats;
>>> +	struct rpc_program	cb_program;
>>>  	struct rpc_create_args args = {
>>>  		.protocol	= IPPROTO_TCP,
>>>  		.address	= (struct sockaddr *)&addr,
>>> @@ -394,6 +381,20 @@ static int do_probe_callback(void *data)
>>>  	addr.sin_port = htons(cb->cb_port);
>>>  	addr.sin_addr.s_addr = htonl(cb->cb_addr);
>>>  
>>> +	/* Initialize rpc_program */
>>> +	memset(&cb_program, 0, sizeof(cb_program));
>>> +	cb_program.name = "nfs4_cb";
>>> +	cb_program.number = clp->cl_callback.cb_prog;
>>> +	cb_program.nrvers = ARRAY_SIZE(nfs_cb_version);
>>> +	cb_program.version = nfs_cb_version;
>>> +	cb_program.stats = &cb_stats;
>>> +	memset(&cb_stats, 0, sizeof(cb_stats));
>>> +	cb_stats.program = &cb_program;
>>>       
>> You don't want a pointer to data on the stack here, do you?
>>     
>
> Hmm, you're right...
> I went back and forth whether this should be allocated statically,
> dynamically, or on the stack.  I was mislead by the fact we're doing
> a sync rpc call, but indeed this needs to live until the nfs client
> is destroyed.  I'm trying to fully understand what Olga saw
> before coming up with a new proposal... maybe putting the cb_program
> back into struct nfs4_callback and just make cb_stats static would
> provide a solution of the problem Olga witnessed and keep everybody
> happy.
>   
I'm trying really hard to remember what was the issue of not using the 
structure and instead using static memory. From what I remember the 
issue was that the memory (clp->cl_callback.cb_prog) was going away.

