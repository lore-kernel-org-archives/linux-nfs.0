Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:60428 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752542Ab2KMAML (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Nov 2012 19:12:11 -0500
Message-ID: <50A1905D.2070608@davequigley.com>
Date: Mon, 12 Nov 2012 19:12:13 -0500
From: Dave Quigley <dpquigl@davequigley.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "David P. Quigley" <selinux@davequigley.com>, trond.myklebust@netapp.com,
        sds@tycho.nsa.gov, linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-security-module@vger.kernel.org,
        "Matthew N. Dodd" <Matthew.Dodd@sparta.com>,
        Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>,
        Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>,
        Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
Subject: Re: [PATCH 02/13] Security: Add Hook to test if the particular xattr
 is part of a MAC model.
References: <1352700947-3915-1-git-send-email-dpquigl@davequigley.com> <1352700947-3915-3-git-send-email-dpquigl@davequigley.com> <20121112121525.GD30713@fieldses.org> <50A10E25.3030704@davequigley.com> <20121112163617.GN30713@fieldses.org> <50A14FA9.8070606@davequigley.com> <20121112214357.GC23169@fieldses.org>
In-Reply-To: <20121112214357.GC23169@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/12/2012 4:43 PM, J. Bruce Fields wrote:
> On Mon, Nov 12, 2012 at 02:36:09PM -0500, David P. Quigley wrote:
>> On 11/12/2012 11:36 AM, J. Bruce Fields wrote:
>>> On Mon, Nov 12, 2012 at 09:56:37AM -0500, Dave Quigley wrote:
>>>> On 11/12/2012 7:15 AM, J. Bruce Fields wrote:
>>>>> On Mon, Nov 12, 2012 at 01:15:36AM -0500, David Quigley wrote:
>>>>>> From: David Quigley<dpquigl@davequigley.com>
>>>>>>
>>>>>> The interface to request security labels from user space is the xattr
>>>>>> interface. When requesting the security label from an NFS server it is
>>>>>> important to make sure the requested xattr
>>>>> I'm confused--clients can't request xattrs from NFS servers.  I must be
>>>>> reading this wrong, but I'm not sure what you meant.
>>>>>
>>>>> --b.
>>>>>
>>>> Generically clients can't use xattrs from NFS servers but the LSM
>>>> method for getting labels is through the xattr interface. THe point
>>>> of this is if someone selects security.capability that we don't
>>>> translate that into a call in labeled nfs to get the security label.
>>>> We only want label based LSMs to cause a getfattr on the server to
>>>> grab the label and populate the inode with that information.
>>>> Currently if you use security.selinux or security.smack then labeled
>>>> nfs will handle the translation of that into a get/setfattr on the
>>>> security_label attribute in NFSv4.
>>> OK, I think I understand: so this is to help the NFS client implement
>>> the necessary xattr interface for userspace that get and sets security
>>> labels on NFS filesystems?
>>>
>>> --b.
>>
>> Exactly. The problem is we don't want to have LSM specific logic in
>> so the best we can do is ask if the security.* xattr being accessed
>> has the proper semantics to be used with Labeled NFS.
>
> OK, thanks.  The changelog could probably be clarified (at least make it
> clear that this is for the client side.)
>
> Delaying this patch till right before the patch that actually uses it
> might also help (and/or even combining those two patches).
>
> --b.
>

I should be able to rearrange them and change the patch text. Merging 
probably isn't a good idea since all of this code is in LSMs so it seems 
weird to put it in with the NFS code.

