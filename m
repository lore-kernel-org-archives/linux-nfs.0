Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29271 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752059AbaCKO4J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Mar 2014 10:56:09 -0400
Message-ID: <531F2334.2030203@RedHat.com>
Date: Tue, 11 Mar 2014 10:52:36 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: NFS <linux-nfs@vger.kernel.org>, "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Carsten Ziepke <kieltux@gmail.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH - v2] mount.nfs: Fix fallback from tcp to udp
References: <20140224142349.784345f9@notabene.brown>	<531E2E3F.2020805@RedHat.com> <20140311090124.05409b1b@notabene.brown>
In-Reply-To: <20140311090124.05409b1b@notabene.brown>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/10/2014 06:01 PM, NeilBrown wrote:
> 
> With  a 3.11.10 client talking to a 3.2.0 server I run
>   rpc.nfsd 0
>   rpc.nfsd -T -N4
> on the server, then
>   rpcinfo -p SERVER | grep nfs
> shows
>     100003    2   udp   2049  nfs
>     100003    3   udp   2049  nfs
>     100227    2   udp   2049  nfs_acl
>     100227    3   udp   2049  nfs_acl
> 
> On client I run
>     mount -v SERVER:/PATH /mnt
> and I get
> mount.nfs: trying text-based options 'vers=4,addr=192.168.1.3,clientaddr=192.168.1.2'
> mount.nfs: mount(2): Connection refused
> 
> repeating ever 10 seconds or so.  It eventually times out after 2 minutes.
> 
> Same client to a 3.10 server I get the same behaviour.
> 3.2.0 client and 3.10 server, same behaviour again.
> 
> I have noticed that sometimes when I stop the NFS server the registration
> with rpcbind doesn't go away.  Not often, but sometimes.  I wonder if that
> could be confusing something?  Can you check that nfsv4 has been
> de-registered from rpcbind?
> 
> I note you are getting the error:
> 
>> mount.nfs: portmap query failed: RPC: Remote system error - Connection refused
> 
> This seems to suggest that rpcbind isn't running.  Yet when I kill rpcbind
> and try a v3 mount I get
> 
>   mount.nfs: portmap query failed: RPC: Unable to receive - Connection refused
> 
> which is slightly different, so presumably there is a different cause in your
> case.
> 
> Maybe you could turn on some rpcdebug tracing to see what is happening?
Ok... I had to dial back my client to an older kernel (3.12)
to start seeing what you were seeing... 

I would make one change and one comment... The change I would
like to make (I'll re-post it) is to ping the server to see
if v4 came up instead of asking rpcbind if its registered. 
Code wise I think it cleaner and quicker plus I'm not sure
its a good idea to tie v4 and rpcbind together... 

My comment is this... This code become obsolete with the 3.13
kernel because the kernel never returns the timeout or the
ECONNREFUSED... The mount just spins in the kernel until
interrupted. 

steved.
