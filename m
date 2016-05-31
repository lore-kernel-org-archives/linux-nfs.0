Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55231 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751616AbcEaSXU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 May 2016 14:23:20 -0400
Subject: Re: Configuring fs_locations on Linux upstream server pseudo fs for
 session trunking
To: "Adamson, Andy" <William.Adamson@netapp.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>
References: <04273F60-806B-4E12-B097-388C346F2DED@oracle.com>
 <40E6E131-029E-4337-A235-B1DB5CA687AA@netapp.com>
Cc: "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <1568116e-5730-0fd0-270d-c66599b0c77f@RedHat.com>
Date: Tue, 31 May 2016 14:23:18 -0400
MIME-Version: 1.0
In-Reply-To: <40E6E131-029E-4337-A235-B1DB5CA687AA@netapp.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

Sorry for coming the party late... 

On 05/25/2016 01:29 PM, Adamson, Andy wrote:
> Anna Schumaker who reviewed my client side session trunking patchset, wants a full featured version of both the client and the server session trunking pieces before accepting the session trunking feature upstream. To that end, I want to implement the server mountd V4ROOT processing of an fs_locations configuration to satisfy an fs_locations request on the pseudo fs.
> 
> The forwarded message is from an email stream between Bruce, Chuck and I concerning the server pseufo fs fs_locations configuration that I’m now sharing with the list.
> 
> Some background:
> 
> The recent "NFSV4.1,2 session trunking” Version-5 patch set sent to the list notes (in patch 00/10):
> 
> The pseudo-fs GETATTR(fs_locations) probe session trunking
> was tested against a Linux server with a pseudo-fs
> export stanza (e.g. a stanza with the fsid=0 or fsid=root
> export option) and a replicas= export option
> (replicas=<path1>@<server1>:<path2>@<server2>..)
> Note that this configuration is for testing only. A future
> patchset will add the replicas= configuration to the
> NFSEXP_V4ROOT nfsd and mountd processing.
> 
> 
> There are several ideas on how to accomplish mountd/V4ROOT fs_locations configuration in the forwarded message. See inline.
> 
> 
>> Begin forwarded message:
>>
>> From: Chuck Lever <chuck.lever@oracle.com>
>> Subject: Re: Configuring fs_locations on Linux upstream server
>> Date: May 6, 2016 at 4:31:00 PM EDT
>> To: "J. Bruce Fields" <bfields@fieldses.org>
>> Cc: "Adamson, Andy" <William.Adamson@netapp.com>
>>
>>
>>> On May 6, 2016, at 4:16 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>>
>>> On Fri, May 06, 2016 at 02:20:12PM -0400, Chuck Lever wrote:
>>>> Seems like when a server does not return a list, that is
>>>> information the client can use: basically, there is no
>>>> ability to do any session trunking. It has to be set up
>>>> explicitly; is that a bad thing, operationally?
>>>
>>> I like the idea of it being opt in on the server.
>>>
>>> Suppose the server transparently starts advertising all available
>>> addresses for session trunking.  It's not hard to imagine cases where
>>> that would go wrong.  E.g., maybe the server has the odd wireless or
>>> 100Mb or other interface that happens to work but that's slow.  Then
>>> somebody upgrades their server and performance goes down and it may take
>>> them a while to figure out why.  Whereas if they'd had to opt in they'd
>>> probably have avoided advertising an inappropriate interface.  Or at
>>> least they'd have a better chance of figuring out that turning on
>>> trunking was what caused the problem.
>>>
>>> I'd rather not force people to export "/" explicitly, though.  It's fine
>>> for testing, but:
>>>
>>> 	- I don't think we give a way to do an explicit V4ROOT export,
>>> 	  so they'd be exposing their entire root partition.  We could
>>> 	  fix that, but
>>> 	- the pseudofs just seems to me like something people shouldn't
>>> 	  normally have to think about.  It's a protocol implementation
>>> 	  detail, I'd rather hide it.  It'd be to easy to configure it a
>>> 	  little wrong, I think.
>>>
>>> We can still do this by adding a replicas= option to the / export, but
>>> we can let rpc.mountd do that internally instead of making the admin add
>>> it to /etc/exports.
>>>
>>> But then you still need a way for the admin to tell rpc.mountd to cook
>>> up the replicas= option.....  I'm not sure what that should look like.
> 
> Idea 1: extra syntax in /etc/exports
As someone said during this thread we really should be moving
away from edit/write/rerun configuration... When you are
talking about 1000s of entries it becomes a bit painful.

> 
> 
>>> Maybe some extra syntax in /etc/exports, but what do they need to give
>>> us--just one list of IP addresses?  Chuck, any ideas?
> 
> Idea 2: xattr attached to “/"
I guess this is not possible... so its out.

> 
>>
>> How about using the same approach used for junctions:
>> put the list in an xattr attached to / ? mountd can
>> extract that when the kernel asks for help satisfying
>> a GETATTR(fs_locations) on V4ROOT.
> 
> 
> Idea 3: new /etc/ config file
>>
>> Or it could be put in a separate config file in /etc.
>> You might want to specify more than just the i/f list
>> here; for instance, the security policy for the
>> pseudofs, or a constant fsid UUID, among other things.
Add new configuration files is become very unpopular in
a particular distro I know of... ;-) and once again 
it comes down managing flat files... 
 
> 
> 
> API to update the i/f list.  This is not about where to hold fs_locations config info, but rather how to insert the (changed) info into the running system.
> 
>>
>> Also, I suggested to Andy earlier:
>>
>>> I find myself leaning towards mechanisms that are easy
>>> both for admins and for programs (ie, an API). Perhaps
>>> one day you might want to add a command that updates the
>>> i/f list from the scripts in /etc/sysconfig/network-scripts,
>>> for instance.
>>>
>>> As part of an ifup:
>>>
>>> nfspfs add <addr>
>>>
>>> and ifdown:
>>>
>>> nfspfs remove <addr>
What happens to this idea? This seems like the most straightforward...

I'm guess I'm leaning for new commands to new stuff instead
of globing on new stuff on old stuff... if that makes any sense. ;-)

Question, these list of ip address are they dynamic? Meaning
can the change on the fly or they are only set on startup
and restarts?

>>>
>>> I wrote some Python code to manipulate entries in
>>> /etc/exports, now found in fedfs-utils. It's icky.
I never like editing files that admins also edit. It
just seems like not a good thing to do.

>>
>>
>> I think we should move away from "edit this file
>> and save it, then restart rpc.xyzpdq". Build some
>> command line interfaces for this.
This what I was thinking about above... 

>>
>> And as you have suggested many times: separate
>> policy from mechanism. /etc/exports is the
>> mechanism.
Hmm.. I see this as adding more complexity to something
that is already complex... 

my two cents,

steved.

>>
>> --
>> Chuck Lever
> 
> Bruce - do you have a preference between #1 and #2 or #3 (or another idea?)
> 
> Thanks
> 
> —>AndyN�����r��y���b�X��ǧv�^�)޺{.n�+����{���"��^n�r���z���h����&���G���h�(�階�ݢj"���m�����z�ޖ���f���h���~�mml==
> 
