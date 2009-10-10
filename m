From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfsmount.conf: New variables that explicitly set default
Date: Fri, 9 Oct 2009 20:38:39 -0400
Message-ID: <BB5B8D78-DAF9-4087-AC84-9BE4F95DA11C@oracle.com>
References: <4ACF7E0D.6060202@RedHat.com> <6E43AB0D-AC26-411F-A8CF-146E02F8AADA@oracle.com> <4ACFC458.8060107@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:39155 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757335AbZJJAlE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Oct 2009 20:41:04 -0400
In-Reply-To: <4ACFC458.8060107-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 9, 2009, at 7:16 PM, Steve Dickson wrote:

> First of all thank you for you comments so soon..
> They are very  much appreciated!
>
> On 10/09/2009 04:29 PM, Chuck Lever wrote:
>> On Oct 9, 2009, at 2:16 PM, Steve Dickson wrote:
>>> This patch introduces two new mount configuration variables used
>>> to set the default protocol version and network transport.
>>>
>>> Currently when the nfsvers or proto is set in the nfsmount.conf
>>> file the mount will fail if the server does not support
>>> the given version or  transport. No negation with the server occurs.
>>>
>>> With default values, they define where the server negation should  
>>> start.
>>> So the 'default_nfsvers=' and default_proto=' will now define  
>>> where the
>>> server negation will start. Meaning just because they are set to a
>>> certain value does not meant that will be the final value used in
>>> mount.
>>>
>>> comments?
>>
>> I worry that this kind of thing will be difficult to support when we
>> move version and transport negotiation into the kernel.
> There was a lot of positive feed back on being able to control
> things like defining the default version and transport from user
> level configuration files. But I do understand your point, so maybe
> its not a good idea to move negotiation down to the kernel. I think  
> its
> clear that is much easier to support and change these types of
> negotiations from user level...

You'd have to take that up with Trond.  Our goal for several years has  
been to handle as much of this as possible in the kernel.

Using a config file in this particular way could make it tougher down  
the road for a kernel implementation.  There might be other mechanisms  
for accomplishing this kind of tuning that might be easier to deal  
with in the kernel.  I'd just like us to think carefully about the  
user interface and API choices we are making right now so we don't  
paint ourselves into a corner.

>>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>>> index 069bdc1..b203414 100644
>>> --- a/utils/mount/stropts.c
>>> +++ b/utils/mount/stropts.c
>>> @@ -92,6 +92,13 @@ struct nfsmount_info {
>>>                child;        /* forked bg child? */
>>> };
>>>
>>> +#ifdef MOUNT_CONFIG
>>> +#include "conffile.h"
>>> +int inline config_defaults(struct nfsmount_info *mi);
>>> +#else
>>> +int inline config_defaults(struct nfsmount_info *mi) {return 0;}
>>> +#endif
>>> +
>>> /*
>>> * Obtain a retry timeout value based on the value of the "retry="
>>> option.
>>> *
>>> @@ -610,10 +617,22 @@ static int nfs_try_mount(struct  
>>> nfsmount_info *mi)
>>>    case 2:
>>>    case 3:
>>>        result = nfs_try_mount_v3v2(mi);
>>> +        if (result)
>>> +            break;
>>> +
>>> +        if (config_defaults(mi))
>>> +            result = nfs_try_mount_v3v2(mi);
>>>        break;
>>> +
>>>    case 4:
>>>        result = nfs_try_mount_v4(mi);
>>> +        if (result)
>>> +            break;
>>> +
>>> +        if (config_defaults(mi))
>>> +            result = nfs_try_mount_v3v2(mi);
>>>        break;
>>> +
>>>    default:
>>>        errno = EIO;
>>>    }
>>
>> A better approach to all of this might be to use the config file to  
>> set
>> mi->version.  mi->version already controls which versions are tried
>> here.  Do away with the idea of adding mount options to get default
>> version behavior.
>>
>> If mi->version is 0, we get full v4/v3/v2 negotiation.  If mi- 
>> >version
>> is 3, we get just v2 and v3.  Do we need any more flexibility than  
>> that?
> Well at the point where the config file is being read, there is no
> access to the struct nfsmount_info since it local to the mount/ 
> stropts.c
> file. That could change but I kinda like the way its designed...
>
>>
>> All you have to do is this: in nfs_validate_options(), after we've
>> looked at the user option string to see what version is specified,
>> check: if mi->version is still 0, then look in the config file to see
>> what kind of negotiation behavior is desired.  Done.
> This does not jive with how the config parsing code works. The code
> appends to the current options (if they don't already exists), well
> before nfs_validate_options() is called..

Right, don't do this particular trick by appending additional mount  
options.  Setting mount's "default version" is not something you want  
to do via existing mount options, for exactly the reasons you stated  
in the patch description.  Likewise with a default protocol.

We have a handful of mount options that adjust mount.nfs's behavior  
rather than specifying the behavior of the mountpoint: bg, fg, and  
retry= being the most obvious examples.  Maybe we want a new mount  
option like defaultvers or defaultproto, which would fall into the  
same category.  But the semantics of the existing vers= and proto=  
options just don't support this kind of thing, and I think we should  
be extremely careful about abusing them like this.

> I'm not saying using the mi->version to start the negotiation is
> bad idea, its just not available when the configuration file
> is read..

What I'm suggesting is that by the time you do get to  
nfs_validate_options() you can read the config file again and look for  
the default version setting.

Alternately, you can read and parse the config file at the start, and  
stuff all that info into a data structure.  Then any place in the code  
can call an API to get what little piece of data they need.

I've seen plenty of apps that read through the config file at whatever  
point they want to look for a particular setting.

>> I'd say you should split the "default protocol" option into a  
>> separate
>> patch, because something quite different will be needed there.
> yeah, that was laziness on my part... But if figured the code was
> not that complicated so I figured I could get away with it..
>
>> But I'm still not clear on why someone wouldn't just say  
>> "proto=udp" or
>> "proto=rdma" to avoid negotiating.
> They can and that's the way it works today... What I'm introducing  
> is a
> negotiable variable that will allow mount to succeed when servers  
> don't
> support the client first offering.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



