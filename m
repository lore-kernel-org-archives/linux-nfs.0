Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.230]:41206 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754195AbZCMV7t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Mar 2009 17:59:49 -0400
Received: by rv-out-0506.google.com with SMTP id g9so798977rvb.5
        for <linux-nfs@vger.kernel.org>; Fri, 13 Mar 2009 14:59:48 -0700 (PDT)
In-Reply-To: <1236980438.7265.47.camel@heimdal.trondhjem.org>
References: <72dbd3150903131336m78526d4ao1308052d6233b70@mail.gmail.com>
	 <1236978608.7265.41.camel@heimdal.trondhjem.org>
	 <72dbd3150903131432u43d9ba43nf0456b99aed0f8fd@mail.gmail.com>
	 <1236980438.7265.47.camel@heimdal.trondhjem.org>
Date: Fri, 13 Mar 2009 14:59:47 -0700
Message-ID: <72dbd3150903131459u273d8e8nc9e966eae01848f7@mail.gmail.com>
Subject: Re: Horrible NFS Client Performance During Heavy Server IO
From: David Rees <drees76@gmail.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Mar 13, 2009 at 2:40 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> Do you perhaps see a lot of sockets connected to port 2049 and that are
> not in the TCP_ESTABLISHED state when you do 'netstat -nt' on the
> server?

Only one tcp socket from the client to the server (no other clients
need to be active when running the testcase).

> What is the ratio of 'write' to 'commit' operations when you look at the
> 'nfsstat -s' output (also on the server)?

It appears to be about 3-4 to 1 writes to commits.  By far the
heaviest activity is with getattr calls with 60-75% of the activity.

# nfsstat -s
Server rpc stats:
calls      badcalls   badauth    badclnt    xdrcall
21044536   0          0          0          0

Server nfs v3:
null         getattr      setattr      lookup       access       readlink
30        0% 12977249 61% 267095    1% 1201529   5% 3030825  14% 4816      0%
read         write        create       mkdir        symlink      mknod
722160    3% 1369511   6% 242484    1% 2852      0% 103       0% 1         0%
remove       rmdir        rename       link         readdir      readdirplus
218097    1% 4354      0% 189125    0% 284       0% 1569      0% 139267    0%
fsstat       fsinfo       pathconf     commit
3930      0% 554       0% 272       0% 610240    2%

And the activity around the time I am reproducing the slowdown:

Server nfs v3:
null         getattr      setattr      lookup       access       readlink
0         0% 3503     75% 7         0% 31        0% 1027     22% 0         0%
read         write        create       mkdir        symlink      mknod
9         0% 50        1% 6         0% 0         0% 0         0% 0         0%
remove       rmdir        rename       link         readdir      readdirplus
2         0% 0         0% 2         0% 0         0% 0         0% 0         0%
fsstat       fsinfo       pathconf     commit
0         0% 0         0% 0         0% 13        0%

-Dave
