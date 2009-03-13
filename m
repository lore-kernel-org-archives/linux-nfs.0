Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.174]:34932 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340AbZCMXFj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Mar 2009 19:05:39 -0400
Received: by wf-out-1314.google.com with SMTP id 28so704328wfa.4
        for <linux-nfs@vger.kernel.org>; Fri, 13 Mar 2009 16:05:37 -0700 (PDT)
In-Reply-To: <1236983389.7265.51.camel@heimdal.trondhjem.org>
References: <72dbd3150903131336m78526d4ao1308052d6233b70@mail.gmail.com>
	 <1236978608.7265.41.camel@heimdal.trondhjem.org>
	 <72dbd3150903131432u43d9ba43nf0456b99aed0f8fd@mail.gmail.com>
	 <1236980438.7265.47.camel@heimdal.trondhjem.org>
	 <72dbd3150903131459u273d8e8nc9e966eae01848f7@mail.gmail.com>
	 <1236983389.7265.51.camel@heimdal.trondhjem.org>
Date: Fri, 13 Mar 2009 16:05:37 -0700
Message-ID: <72dbd3150903131605m6aec6e41j8d608512b2693ba9@mail.gmail.com>
Subject: Re: Horrible NFS Client Performance During Heavy Server IO
From: David Rees <drees76@gmail.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Mar 13, 2009 at 3:29 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Fri, 2009-03-13 at 14:59 -0700, David Rees wrote:
>> And the activity around the time I am reproducing the slowdown:
>>
>> Server nfs v3:
>> null         getattr      setattr      lookup       access       readlink
>> 0         0% 3503     75% 7         0% 31        0% 1027     22% 0         0%
>> read         write        create       mkdir        symlink      mknod
>> 9         0% 50        1% 6         0% 0         0% 0         0% 0         0%
>> remove       rmdir        rename       link         readdir      readdirplus
>> 2         0% 0         0% 2         0% 0         0% 0         0% 0         0%
>> fsstat       fsinfo       pathconf     commit
>> 0         0% 0         0% 0         0% 13        0%
>
> Is this the result of only doing 2 'dd' copies? That's a lot of GETATTR
> calls for that kind of workload...

No - the client that I have been duplicating this from is also my
desktop and the NFS server hosts my home directory and it was active
during the test.

That's where the extreme slowdown in NFS performance affects me the
most.  When then heavy IO on the server is going on (even just a
single process writing as fast as it can), my applications (Firefox,
Thunderbird, Gnome Terminals, just about anything that accesses the
NFS mount) will basically lock up and go totally unresponsive while
they wait for the NFS server to respond.  They will sit unresponsive
for minutes at a time and are unusable until the heavy IO stops on the
server.

I do software development from this machine and I have timed one of my
project builds with and without the heavy IO on the NFS server - a
build that normally takes about 20 seconds will take 5 minutes to
complete (it does read/write a lot of small files).

-Dave
