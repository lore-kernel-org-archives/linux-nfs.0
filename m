Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:36457 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934481Ab1JER1M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Oct 2011 13:27:12 -0400
Message-ID: <4E8C9363.9030303@parallels.com>
Date: Wed, 05 Oct 2011 21:26:59 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>,
        "Kirill A. Shutemov" <kas@openvz.org>,
        "jlayton@redhat.com" <jlayton@redhat.com>
Subject: Re: network-namespace-aware nfsd
References: <20111005150214.GA18449@fieldses.org>
In-Reply-To: <20111005150214.GA18449@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

05.10.2011 19:02, J. Bruce Fields пишет:
> This is a draft outline what we'd need to support containerized nfs
> service; please tell me what I've got wrong.
>
> The goal is to give the impression of running multiple virtual nfs
> services, each with its own ip address or addresses.
>
> A new nfs service will be started by forking off a new network
> namespace, setting up interfaces there, and then starting nfs service
> normally (including starting all the appropriate userland daemons, such
> as rpc.mountd).
>

Hello, Bruce.
What do you mean by "nfs service will be started by forking off a new network 
namespace"?
Does it means, that each nfs service start will create new network namespace?
If so, what about if some process in freshly create namespace will start nfs 
service?

> This requires no changes to existing userland code.  Instead, the kernel
> side of each userland interface needs to be made aware of the network
> namespace of the userland process it is talking to.
>
> The kernel handles requests using a pool of threads, with the number of
> threads controlled by writing to the "threads"  file in the "nfsd"
> filesystem.  The files are also used to start the server (and to stop
> it, by writing zero for the number of threads).
>
> To conserve memory, I would prefer to have all of the virtual servers
> share the same threads, rather than dedicating a separate set of threads
> to each network namespace.  So:
>
> Minimum functionality
> ---------------------
>
> To get something minimal working, we need the rpc work that's in
> progress.
>
> In addition, we need the nfsd/threads interface to remember the value
> set for each network namespace.  Writing to it will adjust the number of
> threads, probably to the maximum value across all namespaces.
>
> In addition, when the per-namespace value changes from zero to nonzero
> or vice-versa, we need to trigger, respectively, starting or stopping
> the per-namespace virtual server.  That means setting up or shutting
> down sockets, and initializing or destroying any per-namespace state (as
> required depending on NFS version, see below).
>
> Also, nfsd/pool_threads probably needs similar treatment.
>
> The nfsd/ports interface allows setting up listening sockets by hand.  I
> suspect it needs at most trivial changes.
>

If I understood you right, you want to share nfsd threads between environments 
and any of this threads can handle requests for different environments.
Am I right?
If not - then what the difference with separated nfs servers?
If yes, then will not we get problems with handling requests to container files 
with changed root?

And what about versions file? If we will share all kernel threads, doesn't it 
means, that we can't tune supported versions per network namespace?

> NFSv4
> -----
>
> To make NFSv4 work, we need per-network-namespace state that is
> initialized and destroyed on startup and shutdown of a virtual nfs
> server.  Each client therefore needs to be associated with a network
> namespace, so it can be shut down at the right time, and so that we
> consistently handle, for example, a broken NFSv4.0 client that sends the
> same long-form identifier to servers with different IP addresses.
>
> For 4.1 we have the option of sharing state between servers if we'd
> like.  Initially simplest is to advertise the servers as entirely
> distinct, without the ability to share any state.
>
> The directory used for recovery data needs to be per-network-namespace.
> If we replace it by something else, we'll need to make sure it's
> namespace-aware.
>
> NFSv2/v3
> --------
>
> For v2/v3 locking to work we also need per-network-namespace lockd and
> statd state.
>

What do you think about lockd kernel thread?
I mean, do you want to share one thread for all network namespaces or create one 
thread per network namespace?

> Note that there is a separate loopback interface per network namespace,
> so the kernel can communicate separately with statd's in different
> namespaces.  (statd communicates with the kernel over the loopback
> interface).
>
> krb5
> ----
>
> Different servers likely want different kerberos identities.  To make
> this work we need separate auth.rpcsec.context and auth.rpcsec.init
> caches for each network namespace.
>
> Independent export trees
> ------------------------
>
> If we want to allow, for example, different filesystems to be exported
> from different virtual servers, then we need per-namespace nfsd.export,
> expkey, and auth.unix.ip caches.
>
> Caches in general
> -----------------
>
> To containerize the /proc/net/rpc/* interfaces (as needed for the krb5
> independent export trees), we need the content, channel, and flush files
> to all be network-namespace-aware, so we want entirely separate caches
> for each namespace.
>
> I'm not sure whether that's best done by having lookups done in each
> namespace get entirely different inodes, or whether the underlying
> inodes should be shared and net/sunrpc/cache.c:cache_open() should
> switch caches based on the network namespace of the opener.
>
> Maybe some day
> --------------
>
> Not urgent, but possibly should be made namespace-aware some day:
>
> 	- leasetime, gracetime: per-netns ideal but not
> 	  required?  Probably more useful for gracetime.
>
> 	- unlock_ip: should be per-netns, maybe, low priority
>
> 	- unlock_fs: should be per-fsns, maybe, ignore for now.
>
> 	- nfs4.idtoname, nfs4.nametoid, could be per-netns, or would
> 	  they need to be per-uidns?
>
> 	- we could allow turning on nfs versions per-netns, but for now
> 	  that seems unnecessary.
>
> 	- maxblksize: ditto.  Keep it global, or take the maximum across
> 	  values given in each netns.
>
> Should be non-issues:
>
> 	- export_features, supported_enctypes: global, nothing
> 	  to do.
>
> 	- filehandle: path->filehandle mapping should already be
> 	  per-fs, hopefully no changes required.
>
> 	- auth.unix.gid
> 		- keep global for now.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Best regards,
Stanislav Kinsbursky
