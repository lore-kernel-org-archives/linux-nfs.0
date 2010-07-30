Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp12.ono.com ([62.42.230.20]:49454 "EHLO resmaa12.ono.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755322Ab0G3ASk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Jul 2010 20:18:40 -0400
Date: Fri, 30 Jul 2010 02:18:37 +0200
From: "J.A. =?ISO-8859-1?B?TWFnYWxs824=?=" <jamagallon@ono.com>
To: Linux Kernel <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: Questions and problems with NFS4
Message-ID: <20100730021837.65549fa7@werewolf.home>
In-Reply-To: <4C507208.6030309@oracle.com>
References: <20100728004611.00c46b13@werewolf.home>
	<4C507208.6030309@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 28 Jul 2010 14:08:08 -0400, Chuck Lever <chuck.lever@oracle.com> wrote:

> On 07/27/10 06:46 PM, J.A. Magallón wrote:
> > - AFAIK, with NFS4 the only needed daemons are nfsd and idmapd. And the
> >    only accesible port from the outside is 2049, for nfsd.
> >    I have tried to strip down my nfs server (-N 2 -N 3 -U),
> >    but rpcinfo still gives me:
> >
> > annwn:~# rpcinfo -p localhost
> >     program vers proto   port  service
> >      100000    4   tcp    111  portmapper
> >      100000    3   tcp    111  portmapper
> >      100000    2   tcp    111  portmapper
> >      100000    4   udp    111  portmapper
> >      100000    3   udp    111  portmapper
> >      100000    2   udp    111  portmapper
> >      100024    1   udp  48461  status
> >      100024    1   tcp  37515  status
> >      100021    1   udp  38583  nlockmgr
> >      100021    3   udp  38583  nlockmgr
> >      100021    4   udp  38583  nlockmgr
> >      100021    1   tcp  37873  nlockmgr
> >      100021    3   tcp  37873  nlockmgr
> >      100021    4   tcp  37873  nlockmgr
> >      100003    4   tcp   2049  nfs
> >      100005    1   udp  45341  mountd
> >      100005    1   tcp  58639  mountd
> >
> >    disabling portampper and mountd is just a matter of initscripts
> >    requirements, but how can I disable nlockmgr ? It isn't needed for
> >    NFS4, isn't it ? Nor portmapper nor mountd...
> 
> Strictly speaking, portmapper is not required for NFSv4 service. 
> However, the NFS infrastructure on Linux is still designed for NFSv2 and 
> v3.  There remains some work needed to make portmapper optional for a 
> v4-only server.  For now, continue to run it in order to handle kernel 
> upcalls.
> 
> rpc.mountd is, however, still required on Linux NFSv4 servers.  Although 
> NFSv4 clients do not contact the server's mountd, the kernel's NFS 
> server performs upcalls to rpc.mountd to manage export information.  You 
> can firewall off the mountd service on the server without affecting 
> NFSv4 clients.  Recent versions of rpc.mountd accept command line 
> options that disable the mountd network service while still handling 
> kernel upcalls.
> 
> And, as long as lockd is running, you will need to keep rpc.statd 
> around.  Again, you can firewall this service so that it is not exposed 
> on the network, but it must continue to be available to handle kernel 
> upcalls.  This is something we hope to address eventually as part of the 
> lockd work Bruce mentioned.

Err...

First of all, plz correct me if this is in some kind of wiki, web page or
the like, but I have not been able to find it. All this things should be
on a document somewhere, perhaps even in the kernel itself...
These are the things I have found out (thanks to your answers...).
I'm a long time unix admin, not new to NFS, but all this things were not
obvious to me, so perhaps they deserve to be in a document, something like
"NFS 3 to 4 migration for dummy admins":

- Everything just works if you mount shares as nfs4. Even, if you have a
  bunch of linux boxen with recent kernel/nfs-utils, probably you are
  already doing nfs4... modern mount tries nfs4 first.

- Using nfsroot with fsid=0 is not mandatory, nor bind-mounting everything
  under some /export (like many documents say), that only forces you to
  use the old way of specifying paths in the server (absolute, not
  relative to /export).

- Even if you use nfsroot(fsid=0), and you mount it on the client
  at /somepoint, you are not forced to mount everything else under
  /somepoint (plz, correct me if I'm wrong).

- You can strip your server for NFS4, but not too much... Old daemons
  are still needed locally. For example, you can get rid of NFS2 and
  UDP for nfsd (-N 2 -U, -any os still uses NFS2??-), and old
  mount protocols (-N 1 -N 2 for mountd)...

- ... but they can be firewalled, use is just local

- portmap/rpcbind is not needed, but still used because nfsd is not
  yet proper clean for only-nfs4-behavior.

There are also some things I have not been able to discover, like
using the interesting things of NFS4:

- How do you activate delegations ? Is this an automatic thing, or
  do I have to add any option somewhere ?

- How do you use cache ? Many docs talk about fsc option, but man
  does not mention it (nfs-utils 1.2.2).
  I have tried to use cachefiles module, and cachefilesd, but
  when I try to run it, I get:

bran:~/c/cachefilesd-0.10# ./cachefilesd -dddns -f $PWD/cachefilesd.conf
About to bind cache
CacheFiles bind failed: errno 95 (Operation not supported)

In dmesg:
[cachef] ==> cachefiles_get_security_ID({system_u:system_r:cachefiles_kernel_t:s0})
CacheFiles: Security denies permission to nominate security context: error -95

I can not run cachefiles without SELinux or something like that ?

Thanks, perhaps this notes help someone in the future. 

TIA

-- 
J.A. Magallon <jamagallon()ono!com>     \               Software is like sex:
                                         \         It's better when it's free
