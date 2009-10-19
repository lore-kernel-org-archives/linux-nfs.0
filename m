From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfsmount.conf: New variables that explicitly set default
Date: Mon, 19 Oct 2009 08:38:32 -0400
Message-ID: <4ADC5DC8.90500@RedHat.com>
References: <4ACF7E0D.6060202@RedHat.com> <6E43AB0D-AC26-411F-A8CF-146E02F8AADA@oracle.com> <4ACFC458.8060107@RedHat.com> <BB5B8D78-DAF9-4087-AC84-9BE4F95DA11C@oracle.com> <4AD2F5B7.9040900@RedHat.com> <21B26104-0D0E-4362-8CE7-B567921B3314@oracle.com> <4AD36309.1090202@RedHat.com> <D9CAEFBB-0B58-43FE-A346-4BDD4150DB92@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40668 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755908AbZJSMiq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Oct 2009 08:38:46 -0400
In-Reply-To: <D9CAEFBB-0B58-43FE-A346-4BDD4150DB92@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/15/2009 11:01 AM, Chuck Lever wrote:
> 
>>>> I would like to stay focus on the technical merit of this patch.
>>>> Meaning are there any holes in that will cause the mount to drop
>>>> core; is there anything I'm missing that will cause mounts to
>>>> unnecessarily fail. Things of that nature...
>>>
>>> I am directly addressing the technical merits of your patch: doing it
>>> your way adds unneeded complexity, breaks aspects of the current
>>> implementation,
>>> goes against the general architecture of mounting a Linux file system,
>> Please.. I'm doing none of the above... All I'm doing is adding a few
>> lines
>> to allow a default values to be set... Lets not go to the extreme... ;-)
> 
> The current patches ignore the principle that I stated (repeatedly) last
> week: you can't diddle the master list of mount options inside the fg/bg
> retry loop.  That's why we need to operate on a fresh copy of that list
> every time through the loop.
> 
> See, once config_defaults() removes the vers= and proto= options from
> mi->options, subsequent iterations of the fg/bg retry loop will no
> longer see those options.  So later mount retries won't be starting from
> the same list of options that the user passed in.  Not to mention what
> that potentially does to this mount's entry in /etc/mtab if the first
> mount attempt doesn't succeed.
> 
> Thus: the patches break aspects of the current implementation, and
> ignore the architecture of text-based NFS mounts.  The last claim above
> was due to a misunderstanding of your patch set.
All this goes away with this release 
    http://marc.info/?l=linux-nfs&m=125578663226042&w=2
Please comment by Tuesday (Oct 20) if so incline to...

> 
>>> I'm not opposed to specifying defaults in the config file, but please
>>> don't do it this way.  I have more of a problem with the specific
>>> implementation you've proposed rather than the idea of setting defaults.
>> You don't like global variables??  That's the only concept I'm
>> introducing that does not already exist.
> 
> We've never before allowed the user to control how mount.nfs negotiates
> unspecified version or transport settings.  Today, the strategy
> mount.nfs uses for unspecified version/transport/port settings always
> works the same way.  And it feels to me like the defaultvers  is
> actually changing the semantics of an existing mount option (vers=) when
> defaultvers is set.  So, you _are_ introducing something entirely new here.
Yes, We are now giving the user more control over how NFS will
negotiate with the server, something on the implementations has
had for years...
  
> 
> I think that having both defaultvers: and nfsvers: is really confusing. 
> What happens when a user uncomments both of them?
nfsvers has precedence... 


> It would be better, just as an example, to combine nfsvers and defaultvers 
> into a single setting, since a user would want exactly one of these behaviors: 
> only v2, only v3, only v4, negotiate v2/v3, or negotiate v2/v3/v4.
No. Setting nfsvers on either the command line or in the config file
means the same thing... No negotiation. When the server does not 
support the given version, the mount will fail. With defaultvers 
there will be a negotiation.

> 
> Having a global nfsvers= setting basically means that no NFS mount on
> that client can ever negotiate the version, doesn't it?  
Exactly, that's why defaultvers is needed...

> Basically, you can't disable that global nfsvers= setting on an individual mount to
> allow it to negotiate -- you can only specify a different specific NFS
> version.  Even setting a vers= on the global, site, or server specific
> option lists has this same behavior, doesn't it?  I posit therefore that
> the only version setting we might want in the config file is the
> defaultvers setting (and not nfsvers: ), and it should be allowed in
> each of the three categories, and on individual mount points.  If/when
> the kernel supports a defaultvers= mount option, we get that behavior
> anyway.
You can disable anything by simply commenting out... but I think you 
are looking as this a bit backwards. The config file is for people 
to *enable* certain option different servers and mount points. So
true the concept of "disabling a global option" does not exist, but 
the ability to change a global option will know exist.
 
> 
> What prevents config_defaults() from removing a vers= or proto= option
> specified by he user for that individual mount, when the default version
> bit is set?  That would be undesirable behavior, yes?  It doesn't seem
> to deal with the synonyms of vers= (nfsvers= and v2 and v3), either.
See http://marc.info/?l=linux-nfs&m=125578663226042&w=2

> 
> The patches ignore the way I designed the switch statement in
> nfs_try_mount().  It's already able to do the correct thing, looking at
> mi->version: if it's 0, it does v4/v3/v2; if it's 2 or 3, it does
> v3/v2.  If there is a vers= option in the option string,
> nfs_validate_options() already sets mi->version properly.  There is no
> need to add any extra logic here whatever for changing the version
> negotiation strategy.  I designed this specifically to support switching
> strategies correctly with minimal fuss, and without making additional
> copies of the options list.  See below to read why I think the default
> version setting has different requirements than the default protocol
> setting.
See http://marc.info/?l=linux-nfs&m=125578663226042&w=2

> 
> If you're passing these global default bit settings around, why can't
> you pass the actual default version and protocol settings instead?  If
> you have the default version setting in a global variable, all you have
> to do is check the value of the global variable in
> nfs_validate_option(), and set mi->version as needed.  That takes care
> of defaultvers= in about 4 lines of very straightforward code (after
> you've added support in configfile.c to set the global variables).
See http://marc.info/?l=linux-nfs&m=125578663226042&w=2

> 
> ----
> 
> We also need to nail down exactly what the "default protocol" setting
> does.  I can easily see how a default version setting in the config file
> would be good, but I'm not clear on why a default protocol setting is
> needed.  Do you have any examples of how this setting might be useful?
Means what it always has meant... which protocol to try first... 

> 
> Does this setting specify a protocol name, or a netid (see mre's feature
> request, RH bz 479350)?  If it's a netid, it could also affect the way
> DNS resolution is done for all mounts on that client -- all servers
> would be contacted by IPv4 or all by IPv6.  If it's not a netid, there's
> no way to specify udp6 or tcp6 for the default value of proto=.
The setting of a protocol will be changing... and when those changes
happen, they will also change in the config file...

> 
> How will NFSv4 mounts, which do not negotiate the transport protocol at
> all, use this setting?  Today, in fact, NFSv4 on Linux uses TCP almost
> to the exclusion of any other transport.  Should mount.nfs append the
> default setting as a proto= option and be done with it, or just ignore
> it?  
The protocol setting is not looked at on v4 mounts, so there is 
absolutely no effect whatsoever...
 
> What happens if the default setting is "rdma" which NFSv4 may not
> support?
We will cross that bridge when we get there. If this is the only
problem people have that are doing rdma mount, that will be a good thing.
 
> 
> Does the default protocol setting also affect the behavior of
> mountproto=?  
Nope. 

> Recall that if neither proto= nor mountproto= is specified, mount.nfs will 
> choose UDP for the MNT protocol, and TCP for the NFS protocol.  
> If the proto= option is specified, that sets both the MNT transport and 
> the NFS transport to the same value.  The user can't
> get that nice default negotiation behavior back once they've set the
> global Proto: setting (just like the nfsvers: setting).
People will *always* have the option of *not* using the config file
it does not meet their needs...

> 
> The correct place to handle a default protocol setting, therefore, is in
> the version-specific negotiation logic ie., _under_ nfs_try_mount(), not
> as part of nfs_try_mount(), since this setting will almost certainly
> behave differently for NFSv4 and NFSv2/v3.  I think default version
> strategy switching is different enough than default protocol strategy
> switching that we are much better off keeping the two entirely
> separate.  Doing otherwise feels a lot like a layering violation to me.
See http://marc.info/?l=linux-nfs&m=125578663226042&w=2

> 
> Consider looking at nfs_probe_bothports() as the place to use a default
> protocol setting to its fullest effectiveness.
> 
> Some potential pitfalls with this implementation:
> 
> ESPIPE is returned in some cases when the server can't be reached....
> this is exactly the case where having config_defaults() remove "proto="
> from the master option list when a default bit is set can result in
> unexpected results subsequent later iterations of the fg/bg loop.
See http://marc.info/?l=linux-nfs&m=125578663226042&w=2

> 
> What happens if there's a "udp" or "tcp" option specified by the user
> (ie. not "proto=tcp", but "tcp")?  config_defaults() seems to ignore
> that possibility.
See http://marc.info/?l=linux-nfs&m=125578663226042&w=2

> 
> How does the retry logic in config_defaults() behave if the server isn't
> responding?  Since it doesn't look at mount.nfs's retry timeout timer
> between tries, wouldn't this introduce longer mount hangs (especially in
> the NFSv4 case)?  Another reason why this probably would be better
> handled in version-specific logic well below nfs_try_mount().
See http://marc.info/?l=linux-nfs&m=125578663226042&w=2

steved.

