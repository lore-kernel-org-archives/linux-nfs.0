From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfsmount.conf: New variables that explicitly set default
Date: Mon, 12 Oct 2009 13:10:33 -0400
Message-ID: <4AD36309.1090202@RedHat.com>
References: <4ACF7E0D.6060202@RedHat.com> <6E43AB0D-AC26-411F-A8CF-146E02F8AADA@oracle.com> <4ACFC458.8060107@RedHat.com> <BB5B8D78-DAF9-4087-AC84-9BE4F95DA11C@oracle.com> <4AD2F5B7.9040900@RedHat.com> <21B26104-0D0E-4362-8CE7-B567921B3314@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42327 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752493AbZJLRLP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Oct 2009 13:11:15 -0400
In-Reply-To: <21B26104-0D0E-4362-8CE7-B567921B3314@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/12/2009 11:16 AM, Chuck Lever wrote:
> 
> On Oct 12, 2009, at 5:24 AM, Steve Dickson wrote:
> 
>> I realize you are philosophically opposed  to having a configure
>> file and allowing people to define defaults. You have made that
>> clear (at least that's my interpretation) from our previous discussions.
> 
> You are reading way too much into this.  I'm not at all trying to stop
> work on the config file.  If I were, why would I have given you clean
> patches to support vers=4 and version negotiation?  Read my lips: I'm
> over it, I've been over it for a while, and I'm now trying to help you
> get it right.
Great!!! Lets move on...

> 
> I might make a similar assumption about your arguments: you are
> philosophically opposed to doing NFS mount processing in the kernel (and
> you've said as much, recently, on this mailing list).  
Yes... I think its a major mistake when it comes to supporting, changing 
and enhancing to push things like this into the kernel.. Remember I
live in world where its literally impossible to changing a kernel but
its fairly easy to replace a package...
  
> Now you are trying your damndest to keep the remaining bits in user space.
> You are fighting an uphill battle, I have to say, since pretty much every
> in-kernel file system does its mount option processing in the kernel
> these days.
Which of those file systems have a network in between their data and media, 
plus do server negation with multiple daemons over multiple network 
transports? Point being... One size does not fit all when it comes to mounting...
 
> 
> So, this is not _my_ idea.  It's the way Linux file systems are
> implemented now.  Thus, we should try to make the mount.nfs config file
> conform to the Linux universe, and not the other way around.
I'll repeat... one size does not fit all... Plus replacing the 
binary interface with the text based interface brought us in
lock step with the rest of the community... IMHO.. 

> 
>> I would like to stay focus on the technical merit of this patch.
>> Meaning are there any holes in that will cause the mount to drop
>> core; is there anything I'm missing that will cause mounts to
>> unnecessarily fail. Things of that nature...
> 
> I am directly addressing the technical merits of your patch: doing it
> your way adds unneeded complexity, breaks aspects of the current implementation, 
> goes against the general architecture of mounting a Linux file system, 
Please.. I'm doing none of the above... All I'm doing is adding a few lines
to allow a default values to be set... Lets not go to the extreme... ;-)

> will make future work in this area more difficult, *and* it will likely 
> prevent us from moving this work into the kernel.
Again, I think this a stretch... The kernel has and always will have 
the final say in how mounts are done.. When kernels changes the user 
level code will follow suite... That's how its been and that's how it 
will be...
 
> 
> I'm not opposed to specifying defaults in the config file, but please
> don't do it this way.  I have more of a problem with the specific
> implementation you've proposed rather than the idea of setting defaults.
You don't like global variables?? That's the only concept I'm
introducing that does not already exist. Building all those interface
you are talking to avoid using one global variable simply not worth
it.. IMHO..    

> 
> We need to approach this with the idea that version and transport
> negotiation will be handled in the kernel, going forward.  The config
> file is a user interface that will need to be designed with the Linux
> mount(2) API in mind.
Like I said, when kernel changes, so will mount.nfs... 

> 
>>> We have a handful of mount options that adjust mount.nfs's behavior
>>> rather than specifying the behavior of the mountpoint: bg, fg, and
>>> retry= being the most obvious examples.  Maybe we want a new mount
>>> option like defaultvers or defaultproto, which would fall into the same
>>> category.  But the semantics of the existing vers= and proto= options
>>> just don't support this kind of thing, and I think we should be
>>> extremely careful about abusing them like this.
>> More mount options??? No... that is not the answer... IMHO..
> 
> I can't see another way of providing a default version and transport to
> the kernel.
> 
> Besides, why would you go to the trouble of adding a global, site, and
> server specific section in the config file, and then limit all of these
> to one default version and protocol?
No. The ideas is to allow those section to explicitly set versions/transport
(similar to setting them on the command line). I see those sections wanting 
to be more static than dynamic... But only time will tell... 

> 
> Instead, you could add a different "defaultvers" setting to each
> section, _and_ have one on a specific mount point in /etc/fstab or in an
> automounter map.  Such a default would then be accessible to every level
> of mount processing, and would provide the maximum flexibility to
> users.  What's not to like about that?
Cool, when that functionally ready to go, the mount command will take 
advantage of it... 

Lets comprise... I'll change the 'default_vers' and 'default_proto'
to 'defaultvers' and 'defaultproto' in the configuration file. So when
the above functionality is available it will be a seamless transition.. 
So in the end, this will just become a bridge patch... Surely you can
stomach that... 8-) 

steved.
