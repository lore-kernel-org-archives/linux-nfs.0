From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfsmount.conf: New variables that explicitly set default
Date: Wed, 21 Oct 2009 16:31:30 -0400
Message-ID: <4ADF6FA2.50801@RedHat.com>
References: <4ACF7E0D.6060202@RedHat.com> <6E43AB0D-AC26-411F-A8CF-146E02F8AADA@oracle.com> <4ACFC458.8060107@RedHat.com> <BB5B8D78-DAF9-4087-AC84-9BE4F95DA11C@oracle.com> <4AD2F5B7.9040900@RedHat.com> <21B26104-0D0E-4362-8CE7-B567921B3314@oracle.com> <4AD36309.1090202@RedHat.com> <D9CAEFBB-0B58-43FE-A346-4BDD4150DB92@oracle.com> <4ADC5DC8.90500@RedHat.com> <10B38617-8037-4CA1-AE90-13F378043E42@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49454 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754871AbZJUUbo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Oct 2009 16:31:44 -0400
In-Reply-To: <10B38617-8037-4CA1-AE90-13F378043E42@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/21/2009 01:37 PM, Chuck Lever wrote:
> On Oct 19, 2009, at 9:38 PM, Steve Dickson wrote:
>> You can disable anything by simply commenting out... but I think you
>> are looking as this a bit backwards. The config file is for people
>> to *enable* certain option different servers and mount points. So
>> true the concept of "disabling a global option" does not exist, but
>> the ability to change a global option will know exist.
> 
> Let's consider specifically for a moment admins who want to make use of
> the config file facility, not folks who want to ignore it.
> 
> As I understand the proposed implementation, if an admin sets
> "defaultvers" in the config file, she alters the mount command's version
> negotiation strategy.  That strategy can be overridden only somewhat for
> specific mount points by setting a specific version.  However, she can't
> allow some mounts to negotiate v4/v3/v2, and others negotiate v3/v2
> only.  The latter would be useful, I think.
No, that functionality does not exist. 

> 
> If she sets "nfsvers" in the config file, she mandates a particular
> version for _all_ mounts on that client, and while specific mounts can
> specify a different version, there's no way to allow specific mount
> points to negotiate the version _at_ _all_, when this option is set.  I
> think that's needlessly inflexible.
Yes, If "nfsvers" is set in the global section, that would turn
off all negotiations, But, if "nfsvers" set in the mount point section 
or server section (which is the expected use), then only those mounts point
defined in the mnt point section or mount to that particular server would 
be effected (i.e. negotiations turned off). All other mounts would not be effect,
meaning version negotiation would happen as expected.

> 
> IMO admins who use the config file would find it more useful if they
> could allow a new negotiation strategy or a specific NFS version to be
> set _anywhere_ in the config file.  For example: "all mounts on this
> server should negotiate v2/v3; all mounts on this other newer server can
> negotiate v2/v3/v4; all mounts on this third server can negotiate
> v2/v3/v4, except these two, which are for a database, and they need v3
> always; for this fourth server, I want to negotiate v2/v3 except for the
> v4 test mount, which can negotiate all three versions".
> 
> Or, simpler: "I want v2/v3 negotiation everywhere, but this test server
> here should be able to negotiate v2/v3/v4."
Or lets let the people that used this config file tell us what they want... 

I would rather not speculate on whether an additional  feature like this 
would be useful. I would rather just give them the config file (as is) 
and the them tell us what is or is not needed...

> 
> A better solution, as I've suggested before, is to have a defaultvers=
> mount option instead.  This provides the flexibility to set a default
> version at _any_ level in the config file, and it even allows previous
> default settings to be overridden on specific mount points.  In
> addition, folks who choose not to use the config file at all can also
> get the ability to specify the default behavior on each mount.  That
> seems like a win-win for everyone.
When the kernel supports a defaultvers mount option, the appropriate changes
will be made...

> 
> In order to get the ability to override config file settings, though,
> you would need to use the "rightmost wins" rule for defaultvers= -- it
> should be able to override NFS version settings earlier in the option
> list.  
I'm not sure what you mean by "it" but the default version can be
overwritten by version being set earlier... 

> That should be simple to implement by having nfs_nfs_version
> leave *version set to zero if the defaultvers= option is rightmost, and
> then have the new logic you added in nfs_validate_options() additionally
> strip off defaultvers= before going ahead with the mount attempts.
> 
> Does that make sense?
Yes. but you are assuming defaultvers is a valid mount option and it is
not. So when/if it does, we can have this discussion then... Plus
what we have today works just fine and if we want to do tweaks like this 
later on, so be it... 

> 
> I can shut up about mount options if you have a stronger argument than
> "aw, not another mount option..." :-)  Otherwise, please convince me
> that a single global default setting is better than allowing negotiation
> to be enabled and disabled anywhere.
As I said, setting the version in the global section of the config file 
probably will not be done. Setting the version/protocol in the mount
point and/or Server section will be done. Mostly to either maintain 
legacy servers or to try new technology like V4, V4.1 and pNFS.

Having the mount point and server section do negotiations, yeah,
that may or may not be a useful thing, only time will tell... 
But I don't think this type of speculation should not stand in 
the way of progress...
 
> 
>>> ----
>>>
>>> We also need to nail down exactly what the "default protocol" setting
>>> does.  I can easily see how a default version setting in the config file
>>> would be good, but I'm not clear on why a default protocol setting is
>>> needed.  Do you have any examples of how this setting might be useful?
>> Means what it always has meant... which protocol to try first...
> 
> The default protocol setting is new, so "what it always has meant" is
> meaningless.  Unless you mean "I'm adding absolutely no new
> functionality here," in which case, why are we bothering to add
> defaultproto: ?
The only new part about is it being exposed... As I'm sure you remember
when the default transport moved from udp to tcp there were a number
of issues. So this does is gives people a way to start with UDP first 
and then try TCP. Will this be norm, no. Will it be recommend, no. 
But will this be useful (and wanted) feature in a very small percentage 
of the world, probably... 

> 
> But I think you miss my point here.  Do you have any specific real world
> examples that demonstrate a problem that can be solved using
> defaultproto= that we haven't been able to solve before now?  Providing
> such examples helps us understand how this feature should behave and be
> implemented.  Basically, it sharpens our implementation to have a target.
No. But I do know people still use UDP instead of TCP so in those 
instances this would a welcome feature... 

> 
> It would help our discussion immensely to see how you intend this to be
> used.  I still can't see what benefit it would have over simply
> specifying proto= where needed.  The benefit of being able to specify a
> default version is clear.  But unlike defaultvers: , the most common
> case, I think, would be simply to disable protocol negotiation, as you
> can already do with proto=.  Otherwise, less hand waving please and more
> concrete examples.
> 
>>> Does this setting specify a protocol name, or a netid (see mre's feature
>>> request, RH bz 479350)?  If it's a netid, it could also affect the way
>>> DNS resolution is done for all mounts on that client -- all servers
>>> would be contacted by IPv4 or all by IPv6.  If it's not a netid, there's
>>> no way to specify udp6 or tcp6 for the default value of proto=.
>> The setting of a protocol will be changing... and when those changes
>> happen, they will also change in the config file...
> 
> The value of defaultvers: is obviously a number, but the value of
> defaultproto: is clearly a string.  We know for certain that we will
> need that value to be a string and not a number in the lower parts of
> the mount code in the near future, so making this a string now would be
> simple to do, and help us out in the long run.
I would rather the config file stay compatible with the command line.
Meaning when the command line option changes, the config file will...

> 
>>> How will NFSv4 mounts, which do not negotiate the transport protocol at
>>> all, use this setting?  Today, in fact, NFSv4 on Linux uses TCP almost
>>> to the exclusion of any other transport.  Should mount.nfs append the
>>> default setting as a proto= option and be done with it, or just ignore
>>> it?
>> The protocol setting is not looked at on v4 mounts, so there is
>> absolutely no effect whatsoever...
> 
> I'm not sure what you mean by that, especially given the previous
> implementation of this patch set which seemed to remove a proto= option
> in logic _above_ the version-specific code in nfs_try_mount().
Keywords being "previous implementation", that is not loner done.
The point is, there is no network protocol negation that goes on
with v4 mounts, so defaultproto does not come into play.

> 
> In addition, proto= does have a meaning for v4, and it has a default
> value: tcp.  It is not negotiated, as it is with v2/v3, true enough. 
> But defaultproto: can have a reasonable meaning for v4: when proto= is
> not specified on v4 mounts, always use the specified protocol setting. 
> (I'm not necessarily arguing in favor of or against this particular
> behavior, but I am trying to get my head around how you want this thing
> to behave).
> 
>>> What happens if the default setting is "rdma" which NFSv4 may not
>>> support?
>> We will cross that bridge when we get there. If this is the only
>> problem people have that are doing rdma mount, that will be a good thing.
> 
> Again, saving a string and not a number right now makes this a lot
> easier down the road.... it would allow us to support rdma here
> immediately, and this would not need to be changed later to get it to
> work.  There's no reason not to do it right the first time.
Again, when the command line changes the configuration file will change.

> 
>>> Does the default protocol setting also affect the behavior of
>>> mountproto=?
>> Nope.
> 
> That's different than the meaning of "proto=" then, as I have described
> below.  So, why do we need defaultproto: but not defaultmountproto: ? 
> Having an example or two of real world usage would help me understand
> the distinction.
If a defaultmountproto is needed down the road, we will put it in...
At this point I don't think there is a needed for it...

> 
>>> Recall that if neither proto= nor mountproto= is specified, mount.nfs
>>> will
>>> choose UDP for the MNT protocol, and TCP for the NFS protocol.
>>> If the proto= option is specified, that sets both the MNT transport and
>>> the NFS transport to the same value.  The user can't
>>> get that nice default negotiation behavior back once they've set the
>>> global Proto: setting (just like the nfsvers: setting).
>> People will *always* have the option of *not* using the config file
>> it does not meet their needs...
> 
> Understood; I'm not arguing against using the config file at all.
> 
> But why would an admin who does choose to use the config file expect or
> want different semantics for proto= and defaultproto: ?
Because they want to switch the order in which the network protocols are tried.
 
Ok... since it appears there are no strictly technical issues (just philosophical 
ones), I think I'm going to move on and commit the patch which will 
give us some building block on which to build from...

Thanks for you input, its greatly appreciated! 

steved.
