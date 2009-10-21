From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfsmount.conf: New variables that explicitly set default
Date: Thu, 22 Oct 2009 02:37:29 +0900
Message-ID: <10B38617-8037-4CA1-AE90-13F378043E42@oracle.com>
References: <4ACF7E0D.6060202@RedHat.com> <6E43AB0D-AC26-411F-A8CF-146E02F8AADA@oracle.com> <4ACFC458.8060107@RedHat.com> <BB5B8D78-DAF9-4087-AC84-9BE4F95DA11C@oracle.com> <4AD2F5B7.9040900@RedHat.com> <21B26104-0D0E-4362-8CE7-B567921B3314@oracle.com> <4AD36309.1090202@RedHat.com> <D9CAEFBB-0B58-43FE-A346-4BDD4150DB92@oracle.com> <4ADC5DC8.90500@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:33413 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754402AbZJURh7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Oct 2009 13:37:59 -0400
In-Reply-To: <4ADC5DC8.90500-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 19, 2009, at 9:38 PM, Steve Dickson wrote:
> On 10/15/2009 11:01 AM, Chuck Lever wrote:
>> I think that having both defaultvers: and nfsvers: is really  
>> confusing.
>> What happens when a user uncomments both of them?
> nfsvers has precedence...
>
>
>> It would be better, just as an example, to combine nfsvers and  
>> defaultvers
>> into a single setting, since a user would want exactly one of these  
>> behaviors:
>> only v2, only v3, only v4, negotiate v2/v3, or negotiate v2/v3/v4.
> No. Setting nfsvers on either the command line or in the config file
> means the same thing... No negotiation. When the server does not
> support the given version, the mount will fail. With defaultvers
> there will be a negotiation.
>
>>
>> Having a global nfsvers= setting basically means that no NFS mount on
>> that client can ever negotiate the version, doesn't it?
> Exactly, that's why defaultvers is needed...
>
>> Basically, you can't disable that global nfsvers= setting on an  
>> individual mount to
>> allow it to negotiate -- you can only specify a different specific  
>> NFS
>> version.  Even setting a vers= on the global, site, or server  
>> specific
>> option lists has this same behavior, doesn't it?  I posit therefore  
>> that
>> the only version setting we might want in the config file is the
>> defaultvers setting (and not nfsvers: ), and it should be allowed in
>> each of the three categories, and on individual mount points.  If/ 
>> when
>> the kernel supports a defaultvers= mount option, we get that behavior
>> anyway.
> You can disable anything by simply commenting out... but I think you
> are looking as this a bit backwards. The config file is for people
> to *enable* certain option different servers and mount points. So
> true the concept of "disabling a global option" does not exist, but
> the ability to change a global option will know exist.

Let's consider specifically for a moment admins who want to make use  
of the config file facility, not folks who want to ignore it.

As I understand the proposed implementation, if an admin sets  
"defaultvers" in the config file, she alters the mount command's  
version negotiation strategy.  That strategy can be overridden only  
somewhat for specific mount points by setting a specific version.   
However, she can't allow some mounts to negotiate v4/v3/v2, and others  
negotiate v3/v2 only.  The latter would be useful, I think.

If she sets "nfsvers" in the config file, she mandates a particular  
version for _all_ mounts on that client, and while specific mounts can  
specify a different version, there's no way to allow specific mount  
points to negotiate the version _at_ _all_, when this option is set.   
I think that's needlessly inflexible.

IMO admins who use the config file would find it more useful if they  
could allow a new negotiation strategy or a specific NFS version to be  
set _anywhere_ in the config file.  For example: "all mounts on this  
server should negotiate v2/v3; all mounts on this other newer server  
can negotiate v2/v3/v4; all mounts on this third server can negotiate  
v2/v3/v4, except these two, which are for a database, and they need v3  
always; for this fourth server, I want to negotiate v2/v3 except for  
the v4 test mount, which can negotiate all three versions".

Or, simpler: "I want v2/v3 negotiation everywhere, but this test  
server here should be able to negotiate v2/v3/v4."

A better solution, as I've suggested before, is to have a defaultvers=  
mount option instead.  This provides the flexibility to set a default  
version at _any_ level in the config file, and it even allows previous  
default settings to be overridden on specific mount points.  In  
addition, folks who choose not to use the config file at all can also  
get the ability to specify the default behavior on each mount.  That  
seems like a win-win for everyone.

In order to get the ability to override config file settings, though,  
you would need to use the "rightmost wins" rule for defaultvers= -- it  
should be able to override NFS version settings earlier in the option  
list.  That should be simple to implement by having nfs_nfs_version  
leave *version set to zero if the defaultvers= option is rightmost,  
and then have the new logic you added in nfs_validate_options()  
additionally strip off defaultvers= before going ahead with the mount  
attempts.

Does that make sense?

I can shut up about mount options if you have a stronger argument than  
"aw, not another mount option..." :-)  Otherwise, please convince me  
that a single global default setting is better than allowing  
negotiation to be enabled and disabled anywhere.

>> ----
>>
>> We also need to nail down exactly what the "default protocol" setting
>> does.  I can easily see how a default version setting in the config  
>> file
>> would be good, but I'm not clear on why a default protocol setting is
>> needed.  Do you have any examples of how this setting might be  
>> useful?
> Means what it always has meant... which protocol to try first...

The default protocol setting is new, so "what it always has meant" is  
meaningless.  Unless you mean "I'm adding absolutely no new  
functionality here," in which case, why are we bothering to add  
defaultproto: ?

But I think you miss my point here.  Do you have any specific real  
world examples that demonstrate a problem that can be solved using  
defaultproto= that we haven't been able to solve before now?   
Providing such examples helps us understand how this feature should  
behave and be implemented.  Basically, it sharpens our implementation  
to have a target.

It would help our discussion immensely to see how you intend this to  
be used.  I still can't see what benefit it would have over simply  
specifying proto= where needed.  The benefit of being able to specify  
a default version is clear.  But unlike defaultvers: , the most common  
case, I think, would be simply to disable protocol negotiation, as you  
can already do with proto=.  Otherwise, less hand waving please and  
more concrete examples.

>> Does this setting specify a protocol name, or a netid (see mre's  
>> feature
>> request, RH bz 479350)?  If it's a netid, it could also affect the  
>> way
>> DNS resolution is done for all mounts on that client -- all servers
>> would be contacted by IPv4 or all by IPv6.  If it's not a netid,  
>> there's
>> no way to specify udp6 or tcp6 for the default value of proto=.
> The setting of a protocol will be changing... and when those changes
> happen, they will also change in the config file...

The value of defaultvers: is obviously a number, but the value of  
defaultproto: is clearly a string.  We know for certain that we will  
need that value to be a string and not a number in the lower parts of  
the mount code in the near future, so making this a string now would  
be simple to do, and help us out in the long run.

>> How will NFSv4 mounts, which do not negotiate the transport  
>> protocol at
>> all, use this setting?  Today, in fact, NFSv4 on Linux uses TCP  
>> almost
>> to the exclusion of any other transport.  Should mount.nfs append the
>> default setting as a proto= option and be done with it, or just  
>> ignore
>> it?
> The protocol setting is not looked at on v4 mounts, so there is
> absolutely no effect whatsoever...

I'm not sure what you mean by that, especially given the previous  
implementation of this patch set which seemed to remove a proto=  
option in logic _above_ the version-specific code in nfs_try_mount().

In addition, proto= does have a meaning for v4, and it has a default  
value: tcp.  It is not negotiated, as it is with v2/v3, true enough.   
But defaultproto: can have a reasonable meaning for v4: when proto= is  
not specified on v4 mounts, always use the specified protocol  
setting.  (I'm not necessarily arguing in favor of or against this  
particular behavior, but I am trying to get my head around how you  
want this thing to behave).

>> What happens if the default setting is "rdma" which NFSv4 may not
>> support?
> We will cross that bridge when we get there. If this is the only
> problem people have that are doing rdma mount, that will be a good  
> thing.

Again, saving a string and not a number right now makes this a lot  
easier down the road.... it would allow us to support rdma here  
immediately, and this would not need to be changed later to get it to  
work.  There's no reason not to do it right the first time.

>> Does the default protocol setting also affect the behavior of
>> mountproto=?
> Nope.

That's different than the meaning of "proto=" then, as I have  
described below.  So, why do we need defaultproto: but not  
defaultmountproto: ?  Having an example or two of real world usage  
would help me understand the distinction.

>> Recall that if neither proto= nor mountproto= is specified,  
>> mount.nfs will
>> choose UDP for the MNT protocol, and TCP for the NFS protocol.
>> If the proto= option is specified, that sets both the MNT transport  
>> and
>> the NFS transport to the same value.  The user can't
>> get that nice default negotiation behavior back once they've set the
>> global Proto: setting (just like the nfsvers: setting).
> People will *always* have the option of *not* using the config file
> it does not meet their needs...

Understood; I'm not arguing against using the config file at all.

But why would an admin who does choose to use the config file expect  
or want different semantics for proto= and defaultproto: ?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



