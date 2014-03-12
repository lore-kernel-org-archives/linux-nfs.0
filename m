Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f47.google.com ([209.85.216.47]:47244 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752974AbaCLJPN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Mar 2014 05:15:13 -0400
Received: by mail-qa0-f47.google.com with SMTP id w5so9576124qac.20
        for <linux-nfs@vger.kernel.org>; Wed, 12 Mar 2014 02:15:12 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH - v2] mount.nfs: Fix fallback from tcp to udp
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140312163803.0e911784@notabene.brown>
Date: Wed, 12 Mar 2014 05:15:09 -0400
Cc: Dickson Steve <SteveD@redhat.com>, NFS <linux-nfs@vger.kernel.org>,
        Dr Fields James Bruce <bfields@fieldses.org>,
        Lever Charles Edward <chuck.lever@oracle.com>,
        Carsten Ziepke <kieltux@gmail.com>
Message-Id: <BAE0F586-4E03-43EB-AC7F-81123D757BDE@primarydata.com>
References: <20140224142349.784345f9@notabene.brown> <531E2E3F.2020805@RedHat.com> <20140311090124.05409b1b@notabene.brown> <531F2334.2030203@RedHat.com> <20140312163803.0e911784@notabene.brown>
To: Brown Neil <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 12, 2014, at 1:38, NeilBrown <neilb@suse.de> wrote:

> On Tue, 11 Mar 2014 10:52:36 -0400 Steve Dickson <SteveD@redhat.com> wrote:
> 
>> On 03/10/2014 06:01 PM, NeilBrown wrote:
>>> 
>>> With  a 3.11.10 client talking to a 3.2.0 server I run
>>>  rpc.nfsd 0
>>>  rpc.nfsd -T -N4
>>> on the server, then
>>>  rpcinfo -p SERVER | grep nfs
>>> shows
>>>    100003    2   udp   2049  nfs
>>>    100003    3   udp   2049  nfs
>>>    100227    2   udp   2049  nfs_acl
>>>    100227    3   udp   2049  nfs_acl
>>> 
>>> On client I run
>>>    mount -v SERVER:/PATH /mnt
>>> and I get
>>> mount.nfs: trying text-based options 'vers=4,addr=192.168.1.3,clientaddr=192.168.1.2'
>>> mount.nfs: mount(2): Connection refused
>>> 
>>> repeating ever 10 seconds or so.  It eventually times out after 2 minutes.
>>> 
>>> Same client to a 3.10 server I get the same behaviour.
>>> 3.2.0 client and 3.10 server, same behaviour again.
>>> 
>>> I have noticed that sometimes when I stop the NFS server the registration
>>> with rpcbind doesn't go away.  Not often, but sometimes.  I wonder if that
>>> could be confusing something?  Can you check that nfsv4 has been
>>> de-registered from rpcbind?
>>> 
>>> I note you are getting the error:
>>> 
>>>> mount.nfs: portmap query failed: RPC: Remote system error - Connection refused
>>> 
>>> This seems to suggest that rpcbind isn't running.  Yet when I kill rpcbind
>>> and try a v3 mount I get
>>> 
>>>  mount.nfs: portmap query failed: RPC: Unable to receive - Connection refused
>>> 
>>> which is slightly different, so presumably there is a different cause in your
>>> case.
>>> 
>>> Maybe you could turn on some rpcdebug tracing to see what is happening?
>> Ok... I had to dial back my client to an older kernel (3.12)
>> to start seeing what you were seeing... 
>> 
>> I would make one change and one comment... The change I would
>> like to make (I'll re-post it) is to ping the server to see
>> if v4 came up instead of asking rpcbind if its registered. 
>> Code wise I think it cleaner and quicker plus I'm not sure
>> its a good idea to tie v4 and rpcbind together... 
> 
> My logic was that if rpcbind was running at all, then any v4 server should
> register with it.  It would seem odd for rpcbind to report "v2 or v3" but for
> v4 to be running anyway.
> However I don't object in principle to your approach.
> I'll have a look at the code.
> 
> 
>> 
>> My comment is this... This code become obsolete with the 3.13
>> kernel because the kernel never returns the timeout or the
>> ECONNREFUSED... The mount just spins in the kernel until
>> interrupted. 
> 
> This sounds like a regression to me.  For a systemcall that used to fail to
> now hang sounds like an API change, and we usually discourage those.
> 
> Can it be fixed?  Trond?

Can someone please provide a test case that confirms that there has been such a change? I would expect the timeouts to have changed due to the NFSv4 trunking detection (which is exactly why it is wrong to rely on the kernel timeouts here anyway), but I would not expect the kernel to never time out at all.

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

