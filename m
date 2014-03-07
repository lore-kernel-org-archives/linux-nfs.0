Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36921 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752858AbaCGQKl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Mar 2014 11:10:41 -0500
Received: by mail-pa0-f48.google.com with SMTP id hz1so4345952pad.35
        for <linux-nfs@vger.kernel.org>; Fri, 07 Mar 2014 08:10:40 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH] Stop Background mounts hang from hanging
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <5319EA25.5060304@RedHat.com>
Date: Fri, 7 Mar 2014 11:10:37 -0500
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <7DA3E2CF-F07F-448E-A907-C4BFE2B36CB4@primarydata.com>
References: <1394204563-1166-1-git-send-email-steved@redhat.com> <D803A861-E660-4D20-BDE1-00D8C45A1228@primarydata.com> <5319EA25.5060304@RedHat.com>
To: Dickson Steve <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 7, 2014, at 10:47, Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 03/07/2014 10:36 AM, Trond Myklebust wrote:
>> 
>> On Mar 7, 2014, at 10:02, Steve Dickson <steved@redhat.com> wrote:
>> 
>>> Background mounts hang forever due to the kernel not returning 
>>> the time out error. The proposed fix is twofold, one in the kernel 
>>> and one in the mounting code.
>>> 
>>> The kernel patch stop the server trunking code from endlessly 
>>> looping in the kernel on -ETIMEDOUT errors. Instead, the code 
>>> will now return the error, allowing the mount to go into 
>>> the background.
>>> 
>>> Unfortunately, it takes over 5 mins for this timeout to 
>>> happen, due the default retry strategy, which is unacceptable 
>>> for background mounts. 
>>> 
>>> So the patch I will be proposing for the mount code will be 
>>> to append the "retrans=1,timeo=100" mount options to the parent
>>> mount of the background mount (when they don't exist). This
>>> causes the parent mount to timeout in ~25sec. 
>> 
>> We already have a ‘retry=‘ option for mount.nfs. According to the manpage, that should be used to specify the timeout value. Why not reuse that?
> Because it didn't work... retrans and timeo had most effect on the initial times set
> in  nfs_init_timeout_values()
> 
>> 
>> Also, it really would be better if that timeout were under control of the mount utility itself. 
> Using those options, it is under the control of mount, unless I'm misunderstanding you...
> 
>> How about if we allow the use of alarm() to interrupt that particular RPC call?
> Why just use the mechanisms that already exist? Why invent a new one? Was my reasoning...

alarm() is hardly a ‘new’ mechanism. It is the standard way of doing this thing in user space, and should, in fact, already work with existing kernels, since they allow fatal signals to interrupt all killable NFS and RPC sleeps.

The point is that relying on ‘retrans’ and ‘timeo’ in this context is likely to be frustrating. ‘retrans’ and ‘timeo’ act on a per RPC call, and there are many RPC calls involved in a single NFSv4/v4.1 mount call. Furthermore, the server may reply with something like DELAY or equivalent, which doesn’t trigger a timeout, but keeps the kernel retrying the same RPC call over and over again.
Then there is the possibility that the hang may occur somewhere other than in the one place you chose (for instance in the path walk). What then?

We can’t and we won’t add a load of stuff to the kernel to catch all the possible sources of delay for a mount operation. That’s why if we can do it in userspace, then we should.
_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

