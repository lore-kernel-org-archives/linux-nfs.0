From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfsmount.conf: New variables that explicitly set default
Date: Thu, 15 Oct 2009 11:01:39 -0400
Message-ID: <D9CAEFBB-0B58-43FE-A346-4BDD4150DB92@oracle.com>
References: <4ACF7E0D.6060202@RedHat.com> <6E43AB0D-AC26-411F-A8CF-146E02F8AADA@oracle.com> <4ACFC458.8060107@RedHat.com> <BB5B8D78-DAF9-4087-AC84-9BE4F95DA11C@oracle.com> <4AD2F5B7.9040900@RedHat.com> <21B26104-0D0E-4362-8CE7-B567921B3314@oracle.com> <4AD36309.1090202@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:19454 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756303AbZJOPCi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Oct 2009 11:02:38 -0400
In-Reply-To: <4AD36309.1090202-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

Thanks for giving me the opportunity to respond.

On Oct 12, 2009, at 1:10 PM, Steve Dickson wrote:
> On 10/12/2009 11:16 AM, Chuck Lever wrote:
>> So, this is not _my_ idea.  It's the way Linux file systems are
>> implemented now.  Thus, we should try to make the mount.nfs config  
>> file
>> conform to the Linux universe, and not the other way around.
> I'll repeat... one size does not fit all... Plus replacing the
> binary interface with the text based interface brought us in
> lock step with the rest of the community... IMHO..

NFS is not in lock step yet.  The text-based mount option  
implementation is not finished, since there are still significant  
pieces of it done in user space.  The v2/v3 version and transport  
negotiation needs to go into the kernel as well; and now that we have  
v4/v3/v2 negotiation, all that has to go in too, in order to be  
completely consistent.  This (at least the v2/v3 part) has been in  
plan for a long while, and it's why I am watching the config file  
patches carefully.

>>> I would like to stay focus on the technical merit of this patch.
>>> Meaning are there any holes in that will cause the mount to drop
>>> core; is there anything I'm missing that will cause mounts to
>>> unnecessarily fail. Things of that nature...
>>
>> I am directly addressing the technical merits of your patch: doing it
>> your way adds unneeded complexity, breaks aspects of the current  
>> implementation,
>> goes against the general architecture of mounting a Linux file  
>> system,
> Please.. I'm doing none of the above... All I'm doing is adding a  
> few lines
> to allow a default values to be set... Lets not go to the  
> extreme... ;-)

The current patches ignore the principle that I stated (repeatedly)  
last week: you can't diddle the master list of mount options inside  
the fg/bg retry loop.  That's why we need to operate on a fresh copy  
of that list every time through the loop.

See, once config_defaults() removes the vers= and proto= options from  
mi->options, subsequent iterations of the fg/bg retry loop will no  
longer see those options.  So later mount retries won't be starting  
from the same list of options that the user passed in.  Not to mention  
what that potentially does to this mount's entry in /etc/mtab if the  
first mount attempt doesn't succeed.

Thus: the patches break aspects of the current implementation, and  
ignore the architecture of text-based NFS mounts.  The last claim  
above was due to a misunderstanding of your patch set.

>> I'm not opposed to specifying defaults in the config file, but please
>> don't do it this way.  I have more of a problem with the specific
>> implementation you've proposed rather than the idea of setting  
>> defaults.
> You don't like global variables??  That's the only concept I'm
> introducing that does not already exist.

We've never before allowed the user to control how mount.nfs  
negotiates unspecified version or transport settings.  Today, the  
strategy mount.nfs uses for unspecified version/transport/port  
settings always works the same way.  And it feels to me like the  
defaultvers  is actually changing the semantics of an existing mount  
option (vers=) when defaultvers is set.  So, you _are_ introducing  
something entirely new here.

I think that having both defaultvers: and nfsvers: is really  
confusing.  What happens when a user uncomments both of them?  You  
have to shape the user interface so users can set only meaningful  
settings, and the UI naturally excludes settings that are not  
meaningful.  It would be better, just as an example, to combine  
nfsvers and defaultvers into a single setting, since a user would want  
exactly one of these behaviors:  only v2, only v3, only v4, negotiate  
v2/v3, or negotiate v2/v3/v4.

Having a global nfsvers= setting basically means that no NFS mount on  
that client can ever negotiate the version, doesn't it?  Basically,  
you can't disable that global nfsvers= setting on an individual mount  
to allow it to negotiate -- you can only specify a different specific  
NFS version.  Even setting a vers= on the global, site, or server  
specific option lists has this same behavior, doesn't it?  I posit  
therefore that the only version setting we might want in the config  
file is the defaultvers setting (and not nfsvers: ), and it should be  
allowed in each of the three categories, and on individual mount  
points.  If/when the kernel supports a defaultvers= mount option, we  
get that behavior anyway.

What prevents config_defaults() from removing a vers= or proto= option  
specified by he user for that individual mount, when the default  
version bit is set?  That would be undesirable behavior, yes?  It  
doesn't seem to deal with the synonyms of vers= (nfsvers= and v2 and  
v3), either.

The patches ignore the way I designed the switch statement in  
nfs_try_mount().  It's already able to do the correct thing, looking  
at mi->version: if it's 0, it does v4/v3/v2; if it's 2 or 3, it does  
v3/v2.  If there is a vers= option in the option string,  
nfs_validate_options() already sets mi->version properly.  There is no  
need to add any extra logic here whatever for changing the version  
negotiation strategy.  I designed this specifically to support  
switching strategies correctly with minimal fuss, and without making  
additional copies of the options list.  See below to read why I think  
the default version setting has different requirements than the  
default protocol setting.

If you're passing these global default bit settings around, why can't  
you pass the actual default version and protocol settings instead?  If  
you have the default version setting in a global variable, all you  
have to do is check the value of the global variable in  
nfs_validate_option(), and set mi->version as needed.  That takes care  
of defaultvers= in about 4 lines of very straightforward code (after  
you've added support in configfile.c to set the global variables).

----

We also need to nail down exactly what the "default protocol" setting  
does.  I can easily see how a default version setting in the config  
file would be good, but I'm not clear on why a default protocol  
setting is needed.  Do you have any examples of how this setting might  
be useful?

Does this setting specify a protocol name, or a netid (see mre's  
feature request, RH bz 479350)?  If it's a netid, it could also affect  
the way DNS resolution is done for all mounts on that client -- all  
servers would be contacted by IPv4 or all by IPv6.  If it's not a  
netid, there's no way to specify udp6 or tcp6 for the default value of  
proto=.

How will NFSv4 mounts, which do not negotiate the transport protocol  
at all, use this setting?  Today, in fact, NFSv4 on Linux uses TCP  
almost to the exclusion of any other transport.  Should mount.nfs  
append the default setting as a proto= option and be done with it, or  
just ignore it?  What happens if the default setting is "rdma" which  
NFSv4 may not support?

Does the default protocol setting also affect the behavior of  
mountproto=?  Recall that if neither proto= nor mountproto= is  
specified, mount.nfs will choose UDP for the MNT protocol, and TCP for  
the NFS protocol.  If the proto= option is specified, that sets both  
the MNT transport and the NFS transport to the same value.  The user  
can't get that nice default negotiation behavior back once they've set  
the global Proto: setting (just like the nfsvers: setting).

The correct place to handle a default protocol setting, therefore, is  
in the version-specific negotiation logic ie., _under_  
nfs_try_mount(), not as part of nfs_try_mount(), since this setting  
will almost certainly behave differently for NFSv4 and NFSv2/v3.  I  
think default version strategy switching is different enough than  
default protocol strategy switching that we are much better off  
keeping the two entirely separate.  Doing otherwise feels a lot like a  
layering violation to me.

Consider looking at nfs_probe_bothports() as the place to use a  
default protocol setting to its fullest effectiveness.

Some potential pitfalls with this implementation:

ESPIPE is returned in some cases when the server can't be reached....  
this is exactly the case where having config_defaults() remove  
"proto=" from the master option list when a default bit is set can  
result in unexpected results subsequent later iterations of the fg/bg  
loop.

What happens if there's a "udp" or "tcp" option specified by the user  
(ie. not "proto=tcp", but "tcp")?  config_defaults() seems to ignore  
that possibility.

How does the retry logic in config_defaults() behave if the server  
isn't responding?  Since it doesn't look at mount.nfs's retry timeout  
timer between tries, wouldn't this introduce longer mount hangs  
(especially in the NFSv4 case)?  Another reason why this probably  
would be better handled in version-specific logic well below  
nfs_try_mount().

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



