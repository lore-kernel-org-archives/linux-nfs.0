From: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Subject: Re: The next step: nfsvers=4
Date: Fri, 17 Apr 2009 18:00:07 -0700
Message-ID: <49E92617.4080504@disney.com>
References: <49C2704F.5050303@RedHat.com> <7A24DF798E223B4C9864E8F92E8C93EC026043D3@SACMVEXC1-PRD.hq.netapp.com> <855593AD-7541-443F-BA92-491EC32FEDFB@oracle.com> <49C28201.1020301@panasas.com> <1FF921B7-4A44-49D7-8E01-1DAC5D18C1AB@oracle.com> <49c29203.85c2f10a.098d.17b5@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Benny Halevy <bhalevy@panasas.com>,
	Steve Dickson <SteveD@redhat.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Tom Talpey <tmtalpey@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate1.disneyanimation.com ([12.188.26.101]:36047 "EHLO
	mailgate1.disneyanimation.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752964AbZDRBAJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Apr 2009 21:00:09 -0400
In-Reply-To: <49c29203.85c2f10a.098d.17b5-ATjtLOhZ0NVl57MIdRCFDg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tom Talpey wrote:
> At 02:13 PM 3/19/2009, Chuck Lever wrote:
>> On Mar 19, 2009, at Mar 19, 2009, 1:33 PM, Benny Halevy wrote:
>>> I think that if no version is specified all versions that
>>> the client supports should be tried, highest first.
>>> Otherwise mount.nfs should try only the specified version.
>> One nit is that the set of mount options supported by nfs4 is  
>> different than the set supported by nfs.  clientaddr= is supported by  
>> nfs4, but not by nfs, for example.  I believe that nocto is not  
>> supported by nfs4.  The mountproto option is only supported by nfs.
>>
>> If no vers= is specified and only NFSv4 is available on the server,  
>> but something like "nocto" shows up on the command line mount options,  
>> do we:
>>
>> a) fail the mount, or
>> b) ignore the nocto option
>>
>> a) seems like the least surprising behavior.
> 
> I think the "sloppy" option might be relevant here too.
> 
> While we're on the subject of sloppy, what about the automounter?
> It has always been an issue to deploy automounter maps which are
> shared by diverse client populations - there are significant issues
> for older Linux clients, and newer Solaris ones for that matter, with
> NFSv4.
> 

I ran into this very situation today which caused me to go back through 
the archive and find this thread.  Hopefully it isn't too late to add my 
two cents.

I want to begin testing nfsv4 in our environment, we rely heavily on 
autofs, and have a mixed OS environment, and some servers support v4, 
while others don't.

Most clients should continue to mount with v3, while a few select test 
machines should mount with v4 if the server supports it.

OSX and (i think) Solaris seem to use fstype=nfs and [nfs]vers=2,3,4 to 
specify the nfs version.  Linux on the other hand, requires that I set 
fstype=nfs4, and will fail to mount if [nfs]vers is present.

If nfsvers was just ignored or better yet, was honored (if I set 
fstype=nfs, and nfsvers=4, I don't really care that you change fstype to 
nfs4 on me under the covers), it would eliminate one hurdle in the quest 
for a unified automount map (at least in our environment).

-kevin

> I would strongly suggest touching and/or changing as few options as
> possible, and paying close attention to the results with legacy or
> generic configurations on new kernels. The more lenient, the better
> IMO, except where specific options require specific actions.
> 
> Tom.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
