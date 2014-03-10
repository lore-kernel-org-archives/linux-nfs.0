Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10277 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751833AbaCJQ6k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Mar 2014 12:58:40 -0400
Message-ID: <531DEF3A.1040401@RedHat.com>
Date: Mon, 10 Mar 2014 12:58:34 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils RPC-PATCH 0/4] Add options to nfsd etc to avoid needing
 to write to /proc
References: <20140220063616.6548.42556.stgit@notabene.brown>	<531B4BB7.9010303@RedHat.com> <20140310114717.7df5c24b@notabene.brown>
In-Reply-To: <20140310114717.7df5c24b@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/09/2014 08:47 PM, NeilBrown wrote:
> On Sat, 08 Mar 2014 11:56:23 -0500 Steve Dickson <SteveD@redhat.com> wrote:
> 
>>
>>
>> On 02/20/2014 01:36 AM, Neil Brown wrote:
>>> There are a number of NFS-related setting that currently must be set
>>> by writing to various files under /proc.
>>> This is a bit clumsy, particularly for systemd unit files.
>>>
>>> So this series adds options to a number of commands where relevant.
>>>
>>> The first two (rdma, and  nfsv4{grace,lease}time) I am quite comfortable with.
>>> The third (nlm grace time) I think is probably right but if someone can argue
>>>  an alternate approach I'm unlikely to resist.
>>> The fourth is .... uhm.  You better look yourself.
>>>
>>> Part of me thinks that nlm port numbers should be set in /etc/sysctl.conf (or sysctl.d)
>>> and /etc/modprobe.d should have something like
>>>
>>>  install lockd  sysctl -p /etc/sysctl.d/lockd
>>>
>>> but last time I tried that it broke "modprobe --show-depends".
>>> Also it is awkward to get setting from /etc/sysconfig/nfs into /etc/sysctl.d/lockd
>>>
>>> Thoughts?
>> I finally got the cycles to take a look at these... My apologies for
>> taking so long... 
> 
> Thanks for getting to it!
> 
>>
>> So I went ahead took a look... Clean them up a bit. There were a couple
>> typos and they did not apply cleanly to my tree...  While I was
>> doing this I got this gnawing feeling that we probably should have
>> some type of global configuration file where all these command
>> line variables can be set. 
>>
>> It would have to be distro friendly meaning the same place in all 
>> distros... Maybe something like /etc/nfsclient.conf patterned off 
>> the /etc/nfsmount.conf config file?? 
>>
>> So I'm thinking it does make sense to have a way to set
>> all these but I'm just not keen on how they are being set.
>> IDK... Maybe I'm over thinking it.. :-)
> 
> I have a couple of (complimentary) thoughts on this.
> 
> My early experience with md/raid raid taught me to be very wary of requiring
> a config file.  The old "raidtools" requires you to make a config file just
> to create an array - or even to stop an array I think.  The new mdadm allows
> you do do everything with command line switches and that makes certain things
> so much easier.
Fair enough... This sounds like wisdom to me... ;-) which is good enough for me!

> 
> When I was experimenting with fallback from v4 to v3 when TCP is not
> supported it was really nice to be able to, e.g.
>   rpc.nfsd 0
>   rpc.nfsd -T 8
> to change nfsd to stop accepting TCP connections.  Had I needed to edit a
> config file every time I did that it would have been a pain.
> 
> This doesn't mean that config file are bad - not at all.  Just that I really
> like that ability to over-ride config files on the command line.
Point taken... 

> 
> Secondly, we already have a config file for NFS.  It is
> call /etc/sysconfig/nfs, though Debian spells it "/etc/default/nfs".
Which is unfortunate, IMHO... To bad we can't meld those together...

> 
> I believe that the best was forward is to make this more standard.
> I think the best way to do this is to teach various nfs utilities to use e.g.
>   getenv("NFS_LISTEN_TCP")
> to get defaults for various settings before parsing command line options.
> Then whatever is used to run these utilities can
>    source /etc/sysconfig/nfs
> or
>    EnvironmentFile=/etc/sysconfig/nfs
> first.
> Thus we have a ready-made configfile name, a ready-made configfile syntax,
> and just need to agree on values can be set.
I think this is a good idea... Which would override which? The command 
line override the environments? What should happen if neither are set?

> 
> A particular value of this approach is  that /etc/sysconfig file are easy for
> admin tools to manipulate.  SUSE's 'yast' allows markup in the file so that
> informative prompts and basic syntax checks can be applied. e.g.:
> 
> ## Path:                Network/File systems/NFS server
> ## Description:         number of threads for kernel nfs server
> ## Type:                integer
> ## Default:             4
> ## ServiceRestart:      nfsserver
> #
> # the kernel nfs-server supports multiple server threads
> #
> USE_KERNEL_NFSD_NUMBER="8"
> 
> We would need to transition from the current setting names to the new agreed
> setting names over a couple of released, but that isn't rocket science and is
> our problem.
I guess this would be that melding I was talking about.. ;-)

> 
> 
> 
>>
>> Finally, during my testing the only flags that seem to work
>> was the statd ones:
>>
>> # rpc.nfsd --rdma 8
>> rpc.nfsd: Unable to request RDMA services: Protocol not supported
> 
> If you don't have configured RDMA hardware on your test machine I would
> expect this.  My testing largely involved running the tool under 'strace'
> and making sure the correct string was written.
> 
>>
>> # rpc.nfsd --grace-time 66
>> rpc.nfsd: Unable to set /proc/fs/nfsd/nfsv4gracetime: Device or resource busy
>>
>> # rpc.nfsd --lease-time 66
>> rpc.nfsd: Unable to set /proc/fs/nfsd/nfsv4leasetime: Device or resource busy
>>
>> Is this expected?
> 
> No..  that was a bit careless.
> The grace-time and leave-time need to be set before the ports are opened.
> 
> i.e. the following incremental patch.  Do you want to merge it with what you
> have, or will I resend that patch (or the whole series)?
Just resend the patch... that will be good enough...

steved.
> 
> Thanks,
> NeilBrown
> 
> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
> index dbd0d98a8e68..32d22d8ab63b 100644
> --- a/utils/nfsd/nfsd.c
> +++ b/utils/nfsd/nfsd.c
> @@ -307,11 +307,17 @@ main(int argc, char **argv)
>  	}
>  
>  	/*
> -	 * must set versions before the fd's so that the right versions get
> +	 * Must set versions before the fd's so that the right versions get
>  	 * registered with rpcbind. Note that on older kernels w/o the right
>  	 * interfaces, these are a no-op.
> +	 * Timeouts must also be set before ports are created else we get
> +	 * EBUSY.
>  	 */
>  	nfssvc_setvers(versbits, minorvers);
> +	if (grace > 0)
> +		nfssvc_set_time("grace", grace);
> +	if (lease  > 0)
> +		nfssvc_set_time("lease", lease);
>  
>  	error = nfssvc_set_sockets(AF_INET, proto4, haddr, port);
>  	if (!error)
> @@ -328,10 +334,6 @@ main(int argc, char **argv)
>  		if (!error)
>  			socket_up = 1;
>  	}
> -	if (grace > 0)
> -		nfssvc_set_time("grace", grace);
> -	if (lease  > 0)
> -		nfssvc_set_time("lease", lease);
>  
>  set_threads:
>  	/* don't start any threads if unable to hand off any sockets */
> 
