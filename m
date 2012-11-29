Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:36335 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752645Ab2K2Le5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2012 06:34:57 -0500
Message-ID: <50B7484A.1030005@parallels.com>
Date: Thu, 29 Nov 2012 15:34:34 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>
Subject: Re: NFSd in container - it works
References: <50B64628.4070007@parallels.com> <20121128200126.GA17875@fieldses.org>
In-Reply-To: <20121128200126.GA17875@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

29.11.2012 00:01, bfields@fieldses.org пишет:
> On Wed, Nov 28, 2012 at 09:13:12PM +0400, Stanislav Kinsbursky wrote:
>> Hi.
>> I have about ~10 more patches, which makes NFS server works in container (mnt + pid + net namesapces). And it passes basic tests.
>
> Good, congratulations.
>

Thanks.

>> But there are some issues I would like to discuss:
>> 1) NFSd threads are running in init_pid namespace. This makes
>> impossible to stop NFS server by signals from container.
>
> Note "rpc.nfsd 0" (which writes to /proc/fs/nfsd/threads) is what
> current Fedora, for example, uses to shut down the server.
>

Yes. this is the only right way. And this is another issue: on containers with old operation system (rhel6, for example), init scripts have to be updated.

> It's not ideal, but for now we can tell people "if you're in a container
> and want to shut down nfsd, you need to use /proc/fs/nfsd/threads, not
> signals."
>

Ok. But there is another issue.
Imagine, that you have container with it's own pid and network namespaces (like OpenVZ container).
You can start NFS server in such container and then kill containers "init" (child reaper), from outside.
Child reaper and all it's children will die. But NFSd kthreads will remain running. And note, that they are holding network namespace currently. Which, actually 
means, that NFS server is still running. Then add one more namespace to this example - mount namespace. Currently it's not hold by NFSd kthreads. And thus NFSd 
kthreads and network namespace can disappear from under NFSd file system (which will be mounted per-net). I'm afraid, that this will lead to kernel panic 
shortly right after any request will be received by NFS server.

So, I see only one proper solution so far:
1) NFSd doesn't hold network references, but instead register it's callback in per-net operations, which will allow to properly shutdown all NFSd kthreads on 
network namespace destruction. This looks sane, because kthreads are started by kernel, and such approach allows to shutdown NFS server properly in case of it's 
child reaper has been killed.
2) NFSd file system holds network namespace. I don't really like this solution, but it look like the only way to make sure, that we don't get to kernel panic, 
mentioned earlier. Moreover, if NFSd file system will be mounted in separated mount namespace, it (mount point) will be unmounted during child reaper exit 
before destroying network namespace.

Have to notice, that if mount namespace is shared between host and container, then NFSd mount point won't be unmounted on child reaper exit, containers NFSd 
kthreads will be running and thus the whole NFSd server will be active after container stop. Situation is not look pleasant, but it's sane and the whole NFSd 
will be properly destructed when NFSd fs is unmounted.

One more note: unmounting of NFSd file system on network namespace shutdown (instead of holding network reference) is another possible solution. This one is 
even better, because we can fully shutdown NFS server on child reaper exit.
But there are a couple of problems:1
1) we have to tie network namespace and mount point (which is not good and not that simple).
2) we have to make sure, that mount point is destroyed before shutdown of kthreads (again, not good and simple).

>> Also is
>> makes possible to stop and destroy container without stopping its
>> NFS server (network namespace thus will stay alive). So, there
>> should be implemented some way to destroy these threads, when
>> container's child reaper is exiting.
>> 2) We need to solve this issue with registering in wrong portmapper.
>> Sync connects suits both Lockd and NFSd. Bruce, what about gss
>> daemon? Maybe some other socket (abstract UNIX or loopback) can be
>> used instead? Or PipeFS?
>
> My vague thought was that the gss-proxy can do a write to a special file
> to indicate that it's up (and thus that it should be used and not the
> old svcgssd interface), and that we could use that process context to do
> the connect....  Not sure if that works.
>

Does it mean, that you don't object against sync transports connect to UNIX sockets?

>> 3) Holding net by tracker looks redundant. What was the reason for this?
>
> I don't understand, what's tracker?
>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Best regards,
Stanislav Kinsbursky
