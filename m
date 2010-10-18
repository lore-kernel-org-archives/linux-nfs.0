Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:55444 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755348Ab0JRPTd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Oct 2010 11:19:33 -0400
Subject: Re: whither NFS umount?
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4CB8B4BC.7070800@RedHat.com>
Date: Mon, 18 Oct 2010 11:18:55 -0400
Cc: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <7FF47D63-DC22-4EC5-B6D1-0CD9A128AC1F@oracle.com>
References: <678C897C-DECE-49C1-AFC4-B57CF3A09385@oracle.com>	<1286903046.24878.13.camel@heimdal.trondhjem.org>	<C5614601-A685-4D7A-8DC3-23375F88AF42@oracle.com>	<20101012151826.76b75f52@corrin.poochiereds.net>	<1286912649.1956.19.camel@heimdal.trondhjem.org>	<4CB5EF15.5030003@RedHat.com>	<20101013141317.66f23906@corrin.poochiereds.net>	<4CB5FE65.3090409@RedHat.com> <20101013145601.468acc2a@corrin.poochiereds.net> <4CB6090F.60301@RedHat.com> <E22DAFE2-A677-4D91-8976-5F641141DD36@oracle.com> <4CB63E81.9010100@RedHat.com> <1BC33C94-1C91-42BE-8FC1-5F85E0D6FABD@oracle.com> <4CB74B90.1050403@RedHat.com> <0F7E614A-3450-48DE-BE44-E0D7CC170B66@oracle.com> <4CB77502.605@RedHat.com> <37D6F414-BDC5-475F-BCC6-27C891D327C0@oracle.com> <4CB8531B.60902@RedHat.com> <80B45DC6-C650-4660-BE52-CD7DA3951FAC@oracle.com> <4CB8B4BC.7070800@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Happy Monday...

On Oct 15, 2010, at 4:08 PM, Steve Dickson wrote:

> On 10/15/2010 12:00 PM, Chuck Lever wrote:
>> On Oct 15, 2010, at 9:11 AM, Steve Dickson wrote:
>> The options in /proc/mounts worked at one point in time, but /etc/mtab 
>> has the options that are probably used every time you do the mount.  
>> They are basically copied from /etc/fstab or the command line.  So we know
>> that, no matter what the server does, the /etc/mtab options are tested and
>> known to allow the client to negotiate the correct settings.
>> 
>>> Now that there is a real possibly that /etc/mtab could deprecated,
>>> I think we should start looking into making the info in /proc/mounts 
>>> work, since /proc/mounts not going anywhere... 
>> 
>> Again, I agree /etc/mtab should be deprecated, but we must not use 
>> /proc/mounts for this purpose.  Save the original mount options and 
>> use them for the umount.  That way the negotiation behavior of the MNT 
>> and the behavior of the UMNT follow exactly the same rules.
> As I've said, we already do use /proc/mounts which is fine.. IMHO.. 

The "fallback to /proc/mounts case" breaks UMNT in exactly the ways I've described.

umount.nfs will use /proc/mounts as a fallback because, without /etc/mtab, that's the only way it can match a mount point directory on the client with the file server name and export information.  However, the mount options can still be incorrect, just as I have described.  Thus this fallback is weak to worthless for sending UMNT (it will get the local umount(2) call right, but that's all that truly matters for the client, anyway).

Using /proc/mounts as a substitute for /etc/mtab works fine for a vast majority of Linux file systems, because during an unmount, they don't care what the mount options were.  They just need to know what device is associated with the mount point being unmounted.

Unfortunately for us, NFS does care about those mount options, and uses /etc/mtab in a way that most other file systems do not.  Yet another reason why no-one else but us chickens cares that a remount can rewrite mount options in /etc/mtab at whim.

>> Let's just write these options to another place besides /etc/mtab, 
>> and read them from that place during unmount.  The only change I'm 
>> talking about is putting a second copy of these options on disk somewhere.
>> 
> I don't think I'm a fan of creating yet another non-scalable
> list we need to maintain.. but that's for another day.. if/when
> /etc/mtab goes away.. 
> 
> For now, I agree with you, lets keep using /etc/mtab to 
> maintain the original options...  

We have to do something now to address this remount bug.  I'm going to code up a patch that stores the mount command line somewhere under /var/run.

Plus, as you have said, /etc/mtab is destined to be removed; has been for some time.  We will have to do this at some point anyway.

-- 
chuck[dot]lever[at]oracle[dot]com




