Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:45474 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755241Ab2EIVCo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 May 2012 17:02:44 -0400
Message-ID: <4FAADB70.3090007@parallels.com>
Date: Thu, 10 May 2012 01:02:40 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: per-net rpc shutdown
References: <20120509142617.GA24233@fieldses.org> <20120509143518.GB24233@fieldses.org>
In-Reply-To: <20120509143518.GB24233@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

09.05.2012 18:35, J. Bruce Fields написал:
> On Wed, May 09, 2012 at 10:26:17AM -0400, J. Bruce Fields wrote:
>> Reviewing your more recent patches I think we have a problem with some
>> of the code that's already merged.  See the comment in svc_shutdown_net:
>>
>> 	void svc_shutdown_net(struct svc_serv *serv, struct net *net)
>> 	{
> By the way, note there's some preexisting trouble here:
>
>> 		/*
>> 		 * The set of xprts (contained in the sv_tempsocks and
>> 		 * sv_permsocks lists) is now constant, since it is modified
>> 		 * only by accepting new sockets (done by service threads in
>> 		 * svc_recv) or aging old ones (done by sv_temptimer), or
>> 		 * configuration changes (excluded by whatever locking the
>> 		 * caller is using--nfsd_mutex in the case of nfsd).
> I don't think the callers are as careful about this as they should be,
> so I think there may be some cases where we could crash if there are
> multiple processes concurrently trying to start, stop, and/or modify the
> listening sockets of a server.
>
> We need to fix that too.
>
> (I haven't actually seen that bug in practice.  We *did* see people hit
> bugs on shutdown of a busy server before fixing the receive/shutdown
> races, though.)
>
> --b.

Looks like we can introduce one more per-service lock, which can be used 
for the list, and it will solve all the issues we have.
One more question here is do we need to protect service shutdown on not. 
Seems to me we don't.
But I'll check it once more.

>> 		So it's
>> 		 * safe to traverse those lists and shut everything down:
>> 		 */
>> 		svc_close_net(serv, net);
>> 	
>> 		if (serv->sv_shutdown)
>> 			serv->sv_shutdown(serv, net);
>> 	}
>>
>> So we depend on the fact that neither the server threads nor
>> sv_temptimer are running here to be able to safely traverse those lists
>> of sockets.
>>
>> But it looks to me like that's no longer true--we're shutting down just
>> one namespace here, and others may still be running.  If so and if they
>> modify sv_tempsocks or sv_permsocks while we're running through them
>> then we're going to get a crash.
>>
>> --b.

