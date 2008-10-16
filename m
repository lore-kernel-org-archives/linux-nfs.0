From: "NeilBrown" <neilb@suse.de>
Subject: Re: [PATCH] sunrpc: make warning in svc_check_conn_limits() more
     generic
Date: Thu, 16 Oct 2008 13:08:22 +1100 (EST)
Message-ID: <fdcfe437d88ecb7d49ea4b2729407dc5.squirrel@neil.brown.name>
References: <1221225127-6042-1-git-send-email-jlayton@redhat.com>
    <20080924215742.GG10841@fieldses.org>
    <20080925162315.6f29d092@tleilax.poochiereds.net>
    <20081015081457.56ef3778@tleilax.poochiereds.net>
    <20081015202102.GC5038@fieldses.org>
    <20081015205118.14de4611@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: "Jeff Layton" <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:35224 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753465AbYJPCIt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Oct 2008 22:08:49 -0400
In-Reply-To: <20081015205118.14de4611-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, October 16, 2008 11:51 am, Jeff Layton wrote:
> On Wed, 15 Oct 2008 16:21:02 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
>
>> On Wed, Oct 15, 2008 at 08:14:57AM -0400, Jeff Layton wrote:
>> > From the descriptions in those commits, it looks like the check
>> > in svc_check_conn_limits was intended to prevent messages from too
>> > many sockets overloading the receive buffers.
>>
>> Aren't the receive buffers per-connection?
>>
>> --b.
>>
>
> Oof...you're quite right. I misunderstood the code earlier. Thinking
> this through a bit more...
>
> I suppose the main worry is that we have a service with too few
> threads and a ton of sockets. We end up in a situation where the
> receive buffers aren't getting processed quickly enough and connections
> start stalling out.
>
> I suppose the only real remedy for that is to increase the number of
> threads, but that's not an option for services like lockd. So maybe
> ignoring this check on single-threaded services is the way to go after
> all? I don't see a way to make this auto-tuning based on memory since
> that doesn't seem to be what the check is intended to help...

Don't expect too much of the "intent" of this limit.
I think it just "seemed like a good idea at the time" with some idea that
a denial of service attack could swamp the NFS server with connections
if we didn't actively close some when there was a large number of them.

The patch which added the test is
http://git.kernel.org/?p=linux/kernel/git/tglx/history.git;a=commitdiff;h=afdb4fa2b04a7e90e0746bc3d031a552656c7709

which says nothing about why.

I found an old Email with a list of things I needed to do to be happy
with TCP support and it included:


- Guard against denial of service - impose some limit on the number of
  incoming connections, and start randomly dropping connections when
  this limit is exceeded.

Which again isn't very helpful.

I certainly wasn't thinking about the possibility of lockd getting
lots of connections despite being a single-thread service.

Maybe we should use
 current->signal->rlim[RLIMIT_NOFILE].rlim_cur
as a minimum limit.  i.e if the number of connections is below this,
allow the connection.  If the number of connections is below the
currently calculated value, also allow the connection.
Only reject if the number is greater than both of these limits.

One problem there is that I don't think you can adjust the RLIMIT_NOFILE
limit for nfsd. It (it think) shares this number with init and all other
kernel threads.

NeilBrown

