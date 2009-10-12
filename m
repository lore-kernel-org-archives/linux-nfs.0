From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfsmount.conf: New variables that explicitly set default
Date: Mon, 12 Oct 2009 11:16:31 -0400
Message-ID: <21B26104-0D0E-4362-8CE7-B567921B3314@oracle.com>
References: <4ACF7E0D.6060202@RedHat.com> <6E43AB0D-AC26-411F-A8CF-146E02F8AADA@oracle.com> <4ACFC458.8060107@RedHat.com> <BB5B8D78-DAF9-4087-AC84-9BE4F95DA11C@oracle.com> <4AD2F5B7.9040900@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:35322 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752918AbZJLPRb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Oct 2009 11:17:31 -0400
In-Reply-To: <4AD2F5B7.9040900-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 12, 2009, at 5:24 AM, Steve Dickson wrote:

> On 10/09/2009 08:38 PM, Chuck Lever wrote:
>>
>> On Oct 9, 2009, at 7:16 PM, Steve Dickson wrote:
>>>>
>>>> I worry that this kind of thing will be difficult to support when  
>>>> we
>>>> move version and transport negotiation into the kernel.
>>> There was a lot of positive feed back on being able to control
>>> things like defining the default version and transport from user
>>> level configuration files. But I do understand your point, so maybe
>>> its not a good idea to move negotiation down to the kernel. I  
>>> think its
>>> clear that is much easier to support and change these types of
>>> negotiations from user level...
>>
>> You'd have to take that up with Trond.  Our goal for several years  
>> has
>> been to handle as much of this as possible in the kernel.
>>
>> Using a config file in this particular way could make it tougher down
>> the road for a kernel implementation.  There might be other  
>> mechanisms
>> for accomplishing this kind of tuning that might be easier to deal  
>> with
>> in the kernel.  I'd just like us to think carefully about the user
>> interface and API choices we are making right now so we don't paint
>> ourselves into a corner.
> Regardless of how much is moved down into the kernel, there
> will always be a mount command that will supply information to
> the kernel via the mount system call. All this config file
> does is provide another way (other than the command line) to supply
> mount with that information. A configuration file [or command line]
> feed the API, they don't define it...


>>>> All you have to do is this: in nfs_validate_options(), after we've
>>>> looked at the user option string to see what version is specified,
>>>> check: if mi->version is still 0, then look in the config file to  
>>>> see
>>>> what kind of negotiation behavior is desired.  Done.
>>> This does not jive with how the config parsing code works. The code
>>> appends to the current options (if they don't already exists), well
>>> before nfs_validate_options() is called..
>>
>> Right, don't do this particular trick by appending additional mount
>> options.  Setting mount's "default version" is not something you  
>> want to
>> do via existing mount options, for exactly the reasons you stated  
>> in the
>> patch description.  Likewise with a default protocol.
> Well that is *exactly* what people want, have complete control
> of their environment, at least that is the feed back I've gotten...

> I realize you are philosophically opposed  to having a configure
> file and allowing people to define defaults. You have made that
> clear (at least that's my interpretation) from our previous  
> discussions.

You are reading way too much into this.  I'm not at all trying to stop  
work on the config file.  If I were, why would I have given you clean  
patches to support vers=4 and version negotiation?  Read my lips: I'm  
over it, I've been over it for a while, and I'm now trying to help you  
get it right.

There is no hidden agenda here.  My interest is a useful and clean  
implementation that is easy to maintain, and fits in with our other  
plans for NFS mounting.  And besides, what possible political  
advantage would there be for me to stymie your project?

I might make a similar assumption about your arguments: you are  
philosophically opposed to doing NFS mount processing in the kernel  
(and you've said as much, recently, on this mailing list).  Now you  
are trying your damndest to keep the remaining bits in user space.   
You are fighting an uphill battle, I have to say, since pretty much  
every in-kernel file system does its mount option processing in the  
kernel these days.

So, this is not _my_ idea.  It's the way Linux file systems are  
implemented now.  Thus, we should try to make the mount.nfs config  
file conform to the Linux universe, and not the other way around.

> I would like to stay focus on the technical merit of this patch.
> Meaning are there any holes in that will cause the mount to drop
> core; is there anything I'm missing that will cause mounts to
> unnecessarily fail. Things of that nature...

I am directly addressing the technical merits of your patch: doing it  
your way adds unneeded complexity, breaks aspects of the current  
implementation, goes against the general architecture of mounting a  
Linux file system, will make future work in this area more difficult,  
*and* it will likely prevent us from moving this work into the kernel.

I'm not opposed to specifying defaults in the config file, but please  
don't do it this way.  I have more of a problem with the specific  
implementation you've proposed rather than the idea of setting defaults.

We need to approach this with the idea that version and transport  
negotiation will be handled in the kernel, going forward.  The config  
file is a user interface that will need to be designed with the Linux  
mount(2) API in mind.

>> We have a handful of mount options that adjust mount.nfs's behavior
>> rather than specifying the behavior of the mountpoint: bg, fg, and
>> retry= being the most obvious examples.  Maybe we want a new mount
>> option like defaultvers or defaultproto, which would fall into the  
>> same
>> category.  But the semantics of the existing vers= and proto= options
>> just don't support this kind of thing, and I think we should be
>> extremely careful about abusing them like this.
> More mount options??? No... that is not the answer... IMHO..

I can't see another way of providing a default version and transport  
to the kernel.

Besides, why would you go to the trouble of adding a global, site, and  
server specific section in the config file, and then limit all of  
these to one default version and protocol?

Instead, you could add a different "defaultvers" setting to each  
section, _and_ have one on a specific mount point in /etc/fstab or in  
an automounter map.  Such a default would then be accessible to every  
level of mount processing, and would provide the maximum flexibility  
to users.  What's not to like about that?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



