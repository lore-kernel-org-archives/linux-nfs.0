From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 0/6][v4][RFC] NFSv3: implement extended attribute protocol
 (XATTR)
Date: Mon, 15 Mar 2010 16:28:57 -0700
Message-ID: <4B9EC2B9.3030800@schaufler-ca.com>
References: <alpine.LRH.2.00.1002261457420.25193@tundra.namei.org> <alpine.LRH.2.00.1003082122340.6314@tundra.namei.org> <20100309035932.GA14237@cynthia.pants.nu> <4B95E167.40306@schaufler-ca.com> <20100309070444.GA18216@cynthia.pants.nu> <20100309193545.GE11042@shareable.org> <4B971611.8030801@schaufler-ca.com> <20100315031951.GU6491@shareable.org> <4B9DBAB0.5060500@schaufler-ca.com> <20100315142803.GC15133@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Brad Boyer <flar-POGeQm5F+FGB+jHODAdFcQ@public.gmane.org>, James Morris <jmorris@namei.org>,
	linux-nfs@vger.kernel.org, linux-security-module@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, linux-fsdevel@vger.kernel.org,
	Casey Schaufler <casey@schaufler-ca.com>
To: Jamie Lokier <jamie@shareable.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp101.prem.mail.sp1.yahoo.com ([98.136.44.56]:33921 "HELO
	smtp101.prem.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S937192Ab0COX26 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Mar 2010 19:28:58 -0400
In-Reply-To: <20100315142803.GC15133@shareable.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jamie Lokier wrote:
> Casey Schaufler wrote:
>   
>> Jamie Lokier wrote:
>>     
>>> Casey Schaufler wrote:
>>>   
>>>       
>>>> Jamie Lokier wrote:
>>>>     
>>>>         
>>>>> Brad Boyer wrote:
>>>>>   
>>>>>       
>>>>>           
>>>>>> On Mon, Mar 08, 2010 at 09:49:27PM -0800, Casey Schaufler wrote:
>>>>>>     
>>>>>>         
>>>>>>             
>>>>>>> Another is to NFS mount the filesystem back on to the server,
>>>>>>> in which case James' scheme works just dandy. It's a trick that
>>>>>>> I've used more than once in the Unix world for this exact purpose.
>>>>>>> Of course you have to arrange your mount points in advance with
>>>>>>> malice aforethought, but that's likely something you're used to
>>>>>>> by now.
>>>>>>>       
>>>>>>>           
>>>>>>>               
>>>>>> That would definitely work, but it's not ideal. Obviously if it's
>>>>>> being accessed over NFS in one place it probably good enough
>>>>>> everywhere, but it's overhead that could be eliminated.
>>>>>>     
>>>>>>         
>>>>>>             
>>>>> As a real example:
>>>>>
>>>>> Each user has a PC with their own home directory being local, fast
>>>>> storage, but /home is filled with NFS auto-mounts to everyone else's
>>>>> home directories, on their individual PCs.  The auto-mount map has an
>>>>> exception, so the local user's home directory is a symlink to the
>>>>> local storage, instead of an NFS mount.
>>>>>
>>>>> A scheme like that works very well for occasional access to other
>>>>> peoples files, and for logging to each other's machines transparently,
>>>>> yet having fast performance for their own files when using their local
>>>>> machine.
>>>>>
>>>>> In an environment where I've used that, forcing local access to go
>>>>> over local NFS would have destroyed performance for things like big
>>>>> compiles, running find, git, grep etc. that people do on their own
>>>>> directories.
>>>>>
>>>>>   
>>>>>       
>>>>>           
>>>> Sure. The original objection can be readily addressed. There are
>>>> performance implications. Just like you'd have if the home directories
>>>> resided on a storage appliance. Some people pick security for the
>>>> masses over performance for the few. Some the other way round.
>>>> It's not an issue for people who want labeled NFS3 badly enough
>>>> to install it.
>>>>     
>>>>         
>>> It seems in this case, the performance implications are totally unnecassary.
>>>
>>> Why not a mount option for the xattr name translation?
>>>
>>>   
>>>       
>> As much as we might like it to be otherwise, an NFS mounted
>> filesystem behaves differently from an ext3 local filesystem.
>> To get consistent behavior the same mechanism needs to be used
>> for all of the machines on which the data is accessed. That
>> means using NFS everywhere because you can't use the local
>> filesystem in multiple places. Usually the variations can be
>> ignored, but there are cases where it matters.
>>     
>
> Sure - but is this case one of them?

Well, that's the debate. If James' NFS3 labeling uses a different
namespace for the label attribute it could very well result in a
difference in behavior. Look at "ls -Z", which reports the value
of a specific attribute.

>   If so, what's the difference?
>
> Sometimes a 10x performance improvement(*) is preferred over rigidly
> consistent behaviour, if the differences don't matter.  Besides, if
> something is working over NFS, it almost certainly works locally.
> Problems only tend to occur the other way around.
>
> I've never yet had a problem running the combination of local mount
> locally and NFS mount remotely on the same filesystem.  This change
> seems to be creating a problem where there wasn't one before - unless
> I'm missing something.
>   

You're missing something. Privilege semantics are different. The
behavior of unlinked files is different. Locking is different. You
are correct that in most cases it does not matter. We're not talking
about the common case, we're talking about using xattrs to store
information that is used to make security decisions. It is quite
difficult to make security claims when an object can be accessed
under two different sets of semantics.


> (*) Measured during big "makes".
>
> -- Jamie
>
>
>   

