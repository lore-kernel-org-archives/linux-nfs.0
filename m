From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [PATCH] mount: enable retry for nfs23 to set the correct protocol for mount.
Date: Mon, 21 Jul 2008 11:32:39 -0400
Message-ID: <76bd70e30807210832l188bd3adl92762d5856bbaa5e@mail.gmail.com>
References: <18556.40594.897682.204554@notabene.brown>
	 <76bd70e30807150811p56feb02bo6e4a366d5577b398@mail.gmail.com>
	 <18559.53893.95829.499988@notabene.brown>
	 <76bd70e30807190909n12b9f70an87ccb62198c3a7d@mail.gmail.com>
	 <18562.57287.656749.540603@notabene.brown>
	 <76bd70e30807201828t70d5b1d0m4c242c5c8864c3bb@mail.gmail.com>
	 <18563.63821.501053.402741@notabene.brown>
	 <76bd70e30807202143q51820814n5a5a0bc0976f9763@mail.gmail.com>
	 <18564.10115.809293.243948@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Steve Dickson" <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: "Neil Brown" <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.190]:48804 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989AbYGUPcl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2008 11:32:41 -0400
Received: by gv-out-0910.google.com with SMTP id e6so129464gvc.37
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2008 08:32:39 -0700 (PDT)
In-Reply-To: <18564.10115.809293.243948-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 21, 2008 at 2:06 AM, Neil Brown <neilb@suse.de> wrote:
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

Perhaps...

> The portmap lookup can be done in userspace, and so "should" be.

Well, the rpcbind step comes quite automatically for the mountd client
in the kernel.  It's part of the RPC state machine for all client
connections.  There is no extra logic in the kernel to do it for the
mountd client.  It's really quite natural for it to do.

> I'm not even convinced that the mount lookup belongs in the kernel,
> though passing a (hex encoded) file handle down might be a bit clumsy.

The mountd client was already in the kernel (used for NFSROOT).  We
simply adopted it for normal mounts too.  User space has absolutely no
need to know the root file handle, but the kernel does.  So I think it
makes more sense for the kernel to handle the mountd lookup.

> But I've decided that there are bigger fish in the sea and I'm going
> to let this one swim away.  As you say, the enterprise releases are
> more important, and it looks like enough fixes will make their way in
> before SLES11 that this won't be an issue any more.
>
> I still hope the other two nfs-utils patches will get in.
>
>>
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

Yes, and the text-based mount command should do that as well if the
initial defaults don't work.

> The text-based mount logic doesn't do what you said any more.
> It default to mountd over TCP thanks to
> nfs_set_mount_transport_protocol().

I will have to look at it again.  My version of this fix, at least,
made the kernel use TCP for mountd and NFS if "proto=tcp" is
specified, UDP for both if "proto=udp" is specified, and TCP for NFS
and UDP for mountd if none were specified.  This is exactly how the
legacy mount command starts off.

If Trond's version of the fix doesn't do that, then that is a behavior
regression.

> Will this be a regression for someone else I wonder ....

-- 
Chuck Lever
