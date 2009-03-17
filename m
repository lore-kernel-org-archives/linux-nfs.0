Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:40951 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751134AbZCQEt4 (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Tue, 17 Mar 2009 00:49:56 -0400
Message-ID: <49BF2D0B.6060108@sgi.com>
Date: Tue, 17 Mar 2009 15:54:35 +1100
From: Greg Banks <gnb@sgi.com>
To: David Rees <drees76@gmail.com>
CC: Trond Myklebust <trond.myklebust@fys.uio.no>, linux-nfs@vger.kernel.org
Subject: Re: Horrible NFS Client Performance During Heavy Server IO
References: <72dbd3150903131336m78526d4ao1308052d6233b70@mail.gmail.com>	 <1236978608.7265.41.camel@heimdal.trondhjem.org>	 <72dbd3150903131432u43d9ba43nf0456b99aed0f8fd@mail.gmail.com>	 <1236980438.7265.47.camel@heimdal.trondhjem.org>	 <72dbd3150903131459u273d8e8nc9e966eae01848f7@mail.gmail.com>	 <1236983389.7265.51.camel@heimdal.trondhjem.org> <72dbd3150903131605m6aec6e41j8d608512b2693ba9@mail.gmail.com>
In-Reply-To: <72dbd3150903131605m6aec6e41j8d608512b2693ba9@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

David Rees wrote:
> On Fri, Mar 13, 2009 at 3:29 PM, Trond Myklebust
> <trond.myklebust@fys.uio.no> wrote:
>   
>> On Fri, 2009-03-13 at 14:59 -0700, David Rees wrote:
>>     
>>> And the activity around the time I am reproducing the slowdown:
>>>
>>> Server nfs v3:
>>> null         getattr      setattr      lookup       access       readlink
>>> 0         0% 3503     75% 7         0% 31        0% 1027     22% 0         0%
>>> read         write        create       mkdir        symlink      mknod
>>> 9         0% 50        1% 6         0% 0         0% 0         0% 0         0%
>>> remove       rmdir        rename       link         readdir      readdirplus
>>> 2         0% 0         0% 2         0% 0         0% 0         0% 0         0%
>>> fsstat       fsinfo       pathconf     commit
>>> 0         0% 0         0% 0         0% 13        0%
>>>       
>> Is this the result of only doing 2 'dd' copies? That's a lot of GETATTR
>> calls for that kind of workload...
>>     
>
> No - the client that I have been duplicating this from is also my
> desktop and the NFS server hosts my home directory and it was active
> during the test.
>
> That's where the extreme slowdown in NFS performance affects me the
> most.  When then heavy IO on the server is going on (even just a
> single process writing as fast as it can), my applications (Firefox,
> Thunderbird, Gnome Terminals, just about anything that accesses the
> NFS mount) will basically lock up and go totally unresponsive while
> they wait for the NFS server to respond.  They will sit unresponsive
> for minutes at a time and are unusable until the heavy IO stops on the
> server.
>
> I do software development from this machine and I have timed one of my
> project builds with and without the heavy IO on the NFS server - a
> build that normally takes about 20 seconds will take 5 minutes to
> complete (it does read/write a lot of small files).
>   
David, could you try your test case with this command running on the server?

tethereal -i eth0 -f 'port 2049' -z rpc,rtt,100003,3 -w /dev/null

and ^C it when you've done.  You should see a table by RPC call with
minimum maximum and average "roundtrip times" (actually as they're
measured on the server, they should be server response times).  This
should tell you which calls are slow and whether it's all those calls or
only a few outliers.

Another experiment worth trying is a local filesystem load fairness test
on the server (no NFS client involved).  This will tell you whether the
nfsd's IO priority is an issue, or if you're just seeing an IO
scheduling issue.

1.  echo 3 > /proc/sys/vm/drop_caches
2.  time find /your/home/some/dir -ls > /dev/null (choose a directory
tree with a few hundred files)
3.  echo 3 > /proc/sys/vm/drop_caches
4.  start your large writes
5.  time find /your/home/some/dir -ls > /dev/null

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

