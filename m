From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] mount: enable retry for nfs23 to set the correct protocol for mount.
Date: Mon, 21 Jul 2008 13:23:22 -0400
Message-ID: <D0ADCD85-2993-4FCE-BE5D-F0926043B7BD@oracle.com>
References: <18556.40594.897682.204554@notabene.brown> <76bd70e30807150811p56feb02bo6e4a366d5577b398@mail.gmail.com> <18559.53893.95829.499988@notabene.brown> <76bd70e30807190909n12b9f70an87ccb62198c3a7d@mail.gmail.com> <18562.57287.656749.540603@notabene.brown> <76bd70e30807201828t70d5b1d0m4c242c5c8864c3bb@mail.gmail.com> <18563.63821.501053.402741@notabene.brown> <76bd70e30807202143q51820814n5a5a0bc0976f9763@mail.gmail.com> <18564.10115.809293.243948@notabene.brown>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:17108 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971AbYGURZA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2008 13:25:00 -0400
In-Reply-To: <18564.10115.809293.243948-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 21, 2008, at 2:06 AM, Neil Brown wrote:

> On Monday July 21, chucklever@gmail.com wrote:
>>
>> The workaround for older nfs-utils has been to specify
>> "mountproto=udp/tcp" explicitly.
>
> Yes, that's a usable workaround.
>
>> I think this works around the problem of having a server who's
>> portmapper listens only on TCP.  The underlying portmap client in the
>> mount command (and in the kernel) should be able to deal with that
>> without tying the rpcbind transport to the transport that is being
>> queried, and that is what is truly broken here.
>>
>> So I think I would rather see this problem addressed in the
>> portmap/rpcbind client implementations and not in the upper level
>> mountd clients.  If a portmap query doesn't work over UDP, it seems
>> like it should try it over TCP instead, and then remember that for
>> later queries.
>>
>> I think your objection would be that this doesn't address the
>> regression for particular combinations of nfs-utils and kernel
>> versions, but I don't have a better suggestion at the moment.
>
> My other objection is the you are pushing too much functionality into
> the kernel.
> The portmap lookup can be done in userspace, and so "should" be.
> I'm not even convinced that the mount lookup belongs in the kernel,
> though passing a (hex encoded) file handle down might be a bit clumsy.
>
> But I've decided that there are bigger fish in the sea and I'm going
> to let this one swim away.  As you say, the enterprise releases are
> more important, and it looks like enough fixes will make their way in
> before SLES11 that this won't be an issue any more.
>
> I still hope the other two nfs-utils patches will get in.

FWIW, I'm comfortable with your suggested changes to sm-notify and  
with using connected UDP sockets where we can in mount.nfs.

In combination with using connected UDP sockets for kernel RPC  
clients, and with the recent fixes to the kernel's mount option parser  
to use appropriate transport protocol defaults, I think we will be in  
much better shape.

>> Again, I may not be clear on the original requirements here.  My
>> understanding is that the legacy mount command uses default settings
>> if "proto/mountproto" are not specified.  It does not attempt to use
>> "the best" settings unless the default settings don't work.  This is
>> what the text-based mount logic does -- it uses default settings
>> (NFSv3 over TCP, mountd v3 over UDP), then punts if it needs service
>> discovery.
>
> "requirements"? that would be nice?
> The legacy code tries every possibly combination of values that
> weren't explicitly given until it finds a combination that "works".
> It goes from most desirable to least desirable.
>
> The text-based mount logic doesn't do what you said any more.
> It default to mountd over TCP thanks to
> nfs_set_mount_transport_protocol().
>
> Will this be a regression for someone else I wonder ....
>
> NeilBrown
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



