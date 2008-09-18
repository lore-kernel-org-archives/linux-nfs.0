From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH] nfsd: use nfs client rpc callback program
Date: Wed, 17 Sep 2008 19:10:28 -0500
Message-ID: <48D19C74.8000303@panasas.com>
References: <48D15DF0.4000406@panasas.com> <20080917231018.GA5723@fieldses.org> <48D193EE.2020805@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, pnfs mailing list <pnfs@linux-nfs.org>
To: Olga Kornievskaia <aglo@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:25318 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752443AbYIRAJ6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Sep 2008 20:09:58 -0400
In-Reply-To: <48D193EE.2020805@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep. 17, 2008, 18:34 -0500, Benny Halevy <bhalevy@panasas.com> wrote:
> On Sep. 17, 2008, 18:10 -0500, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>> On Wed, Sep 17, 2008 at 02:43:44PM -0500, Benny Halevy wrote:
>>> From: Benny Halevy <bhalevy@panasas.com>
>>>
>>> since commit ff7d9756b501744540be65e172d27ee321d86103
>>> "nfsd: use static memory for callback program and stats"
>>> do_probe_callback uses a static callback program
>>> (NFS4_CALLBACK) rather than the one set in clp->cl_callback.cb_prog
>>> as passed in by the client in setclientid (4.0)
>>> or create_session (4.1).
>> Ugh, yes, sorry about that.  (I wonder why pynfs testing didn't catch
>> this?  Oh, I guess it's because NFS4_CALLBACK is the program number our
>> client always gives us.)
> 
> Well, Fred (thanks!) added a test today which uses a non-default
> callback program and he sees a corresponding callback coming back.
> 
> (Note that this test is not absolutely generic as the server is
> not required to probe the callback immediately, or at all, after
> setclientid or create_session.)
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
>> You don't want a pointer to data on the stack here, do you?
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

It looks like the gss_cred references the rpc_client and that is used
in gss_destroying_context.  However, I couldn't find a call to 
rpc_release_client from the gss_cred destruction path.

Shouldn't gss_create formally kref the clnt and gss_free_cred
call rpc_release_client(gss_cred->client)?

If so, I think we could teach the rpc_client to allocate the
program and stats dynamically and let rpc_free_client() to free them
along with the rpc_client.

Benny

> 
> Benny
> 
>> --b.
> 
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
