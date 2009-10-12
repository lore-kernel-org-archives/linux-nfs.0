From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfsmount.conf: New variables that explicitly set default
Date: Mon, 12 Oct 2009 05:24:07 -0400
Message-ID: <4AD2F5B7.9040900@RedHat.com>
References: <4ACF7E0D.6060202@RedHat.com> <6E43AB0D-AC26-411F-A8CF-146E02F8AADA@oracle.com> <4ACFC458.8060107@RedHat.com> <BB5B8D78-DAF9-4087-AC84-9BE4F95DA11C@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12057 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754894AbZJLJYt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Oct 2009 05:24:49 -0400
In-Reply-To: <BB5B8D78-DAF9-4087-AC84-9BE4F95DA11C@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/09/2009 08:38 PM, Chuck Lever wrote:
> 
> On Oct 9, 2009, at 7:16 PM, Steve Dickson wrote:
>>>
>>> I worry that this kind of thing will be difficult to support when we
>>> move version and transport negotiation into the kernel.
>> There was a lot of positive feed back on being able to control
>> things like defining the default version and transport from user
>> level configuration files. But I do understand your point, so maybe
>> its not a good idea to move negotiation down to the kernel. I think its
>> clear that is much easier to support and change these types of
>> negotiations from user level...
> 
> You'd have to take that up with Trond.  Our goal for several years has
> been to handle as much of this as possible in the kernel.
> 
> Using a config file in this particular way could make it tougher down
> the road for a kernel implementation.  There might be other mechanisms
> for accomplishing this kind of tuning that might be easier to deal with
> in the kernel.  I'd just like us to think carefully about the user
> interface and API choices we are making right now so we don't paint
> ourselves into a corner.
Regardless of how much is moved down into the kernel, there
will always be a mount command that will supply information to
the kernel via the mount system call. All this config file
does is provide another way (other than the command line) to supply 
mount with that information. A configuration file [or command line]
feed the API, they don't define it... 
 

>>>
>>> All you have to do is this: in nfs_validate_options(), after we've
>>> looked at the user option string to see what version is specified,
>>> check: if mi->version is still 0, then look in the config file to see
>>> what kind of negotiation behavior is desired.  Done.
>> This does not jive with how the config parsing code works. The code
>> appends to the current options (if they don't already exists), well
>> before nfs_validate_options() is called..
> 
> Right, don't do this particular trick by appending additional mount
> options.  Setting mount's "default version" is not something you want to
> do via existing mount options, for exactly the reasons you stated in the
> patch description.  Likewise with a default protocol.
Well that is *exactly* what people want, have complete control
of their environment, at least that is the feed back I've gotten...

I realize you are philosophically opposed  to having a configure
file and allowing people to define defaults. You have made that 
clear (at least that's my interpretation) from our previous discussions.
I understand that and truly do respect that opinion... But there has 
been an overwhelming acceptance from other parts of the community 
so I'm hard pressed to let this one opinion stand in the way of 
that acceptance.... So with that said... 

I would like to stay focus on the technical merit of this patch. 
Meaning are there any holes in that will cause the mount to drop
core; is there anything I'm missing that will cause mounts to
unnecessarily fail. Things of that nature...     
 
> 
> We have a handful of mount options that adjust mount.nfs's behavior
> rather than specifying the behavior of the mountpoint: bg, fg, and
> retry= being the most obvious examples.  Maybe we want a new mount
> option like defaultvers or defaultproto, which would fall into the same
> category.  But the semantics of the existing vers= and proto= options
> just don't support this kind of thing, and I think we should be
> extremely careful about abusing them like this.
More mount options??? No... that is not the answer... IMHO..

> 
>> I'm not saying using the mi->version to start the negotiation is
>> bad idea, its just not available when the configuration file
>> is read..
> 
> What I'm suggesting is that by the time you do get to
> nfs_validate_options() you can read the config file again and look for
> the default version setting.
After look at this, I see it really does not matter when and where
the file is read. And yes if the file was read from nfs_validate_options()
than yes I could set mi->version to do the negotiation, but that does
not take care of the network transport negotiation part of it... Meaning
the "proto" would still have to be removed to do the renegotiation... 

So the purposed patch is the better approach, at this point, since it handle
both types of negotiation in the same place, in the same way... 

> 
> Alternately, you can read and parse the config file at the start, and
> stuff all that info into a data structure.  Then any place in the code
> can call an API to get what little piece of data they need.
I don't want to add this type of complexity... Its simply not needed,
to solve this issue...  

steved.
