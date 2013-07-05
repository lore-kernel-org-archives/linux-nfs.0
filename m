Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:43305 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757345Ab3GEPAJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Jul 2013 11:00:09 -0400
Content-Type: text/plain; charset=US-ASCII
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: [PATCH] Disable NFS version 2
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <51D6AE7D.9070805@RedHat.com>
Date: Fri, 5 Jul 2013 10:59:59 -0400
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <4408EEAB-97F1-404A-BC58-434729D12364@oracle.com>
References: <1372856675-5520-1-git-send-email-steved@redhat.com> <9A7F190A-2938-4A14-9125-330189DA8597@oracle.com> <51D6AE7D.9070805@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

On Jul 5, 2013, at 7:31 AM, Steve Dickson <SteveD@redhat.com> wrote:

> Hey,
> 
> On 03/07/13 09:19, Chuck Lever wrote:
>> Hi-
>> 
>> I'm not opposed to this change, but we should have some public discussion about it first.
>> 
>> If we make this proposed upstream change, NFSv2 will be built far less often and will be 
>> a magnet for code rot.  It might make more sense to simply leave the "compile this out" 
>> choice up to distributions...?
> Code rot is a possibility for any code where default is 'n' so that means we should
> never use it? If that is the case, we should have swap over NFS and Label NFS 
> on be default on by default so those bits don't rote... My point being, I don't
> think code rot should be a reason for us to maintain code people should not
> be using in the first place...

In the case at hand, code rot isn't much of a risk if the point is to remove a feature.  But that point wasn't stated anywhere.

>> I'd like to reduce the risk of the kernel carrying  around code that no-one uses or 
>> compiles.  If we truly want this off by default  everywhere, shouldn't we just 
>> remove it?  (Is that the eventual goal?)
> I would think so. Turn it off and see who screams.. Then get the clue-bat out for
> for those people that do scream... ;-)  They can always turn it back on... 

If deprecation is the long-term goal, we ought to have a stated plan that we all agree on.  We're talking about removing a feature of Linux NFS that has been a mainstay for, literally, decades.  Make some noise, let people chime in, and publish a plan so folks know what to expect.

We should also document publicly why we think NFSv2 support should go away.  Is it a significant maintenance burden?  Is it a security problem?  Who are the stakeholders?

>> Should the server also disable NFSv2 support by default?  If not, then why is the 
>> client special in this regard?
> We have to start somewhere... It was just easier to start with the client. If 
> Bruce is interested in dropping v2 support on the server, I will be more than
> willing to looking into that... Actually it might just be a nfs-utils only thing...

It feels like we should have a plan for both the server and client.

You could remove NFSv2 support in nfs-utils on both sides, I would think.  Didn't you already remove NFSv2 from the mount.nfs command's version negotiation?

Deprecating a kernel feature also has a pathway through the staging tree, IIUC.  Would that be appropriate for NFSv2?  It may even be a requirement these days, but I'm not sure.

>> Finally, if we go with something like this change, does this patch also need to 
>> update the default configurations shipped with the kernel?
> What "default configurations shipped with the kernel"? Isn't fs/nfs/Kconfig the
> only place I need to turn it off?

arch/*/configs/*_defconfig

These were not updated when the NFS client was modularized, so they currently do not list an explicit CONFIG_NFS_V2 setting.  IIUC that means changing Kconfig ought to be enough.

> Thanks for the cycles!
> 
> steved.
> 
>> 
>> 
>> On Jul 3, 2013, at 9:04 AM, Steve Dickson <steved@redhat.com> wrote:
>> 
>>> This patch disables the NFS version 2 module from being compile by default.
>>> 
>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>> ---
>>> fs/nfs/Kconfig | 4 ++--
>>> 1 file changed, 2 insertions(+), 2 deletions(-)
>>> 
>>> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
>>> index 13ca196..6831a01 100644
>>> --- a/fs/nfs/Kconfig
>>> +++ b/fs/nfs/Kconfig
>>> @@ -32,12 +32,12 @@ config NFS_FS
>>> config NFS_V2
>>> 	tristate "NFS client support for NFS version 2"
>>> 	depends on NFS_FS
>>> -	default y
>>> +	default n
>>> 	help
>>> 	  This option enables support for version 2 of the NFS protocol
>>> 	  (RFC 1094) in the kernel's NFS client.
>>> 
>>> -	  If unsure, say Y.
>>> +	  If unsure, say n.
>>> 
>>> config NFS_V3
>>> 	tristate "NFS client support for NFS version 3"
>>> -- 
>>> 1.8.1.4
>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




