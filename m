Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:24186 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751039AbdGGEOb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Jul 2017 00:14:31 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH nfs-utils v2 05/12] getport: recognize "vsock" netid
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <87wp7lvst9.fsf@notabene.neil.brown.name>
Date: Fri, 7 Jul 2017 00:14:19 -0400
Cc: Stefan Hajnoczi <stefanha@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>
Message-Id: <00E66803-089E-415C-94E4-D2BEBD37AEF6@oracle.com>
References: <20170630132120.31578-1-stefanha@redhat.com> <20170630132120.31578-6-stefanha@redhat.com> <952499A1-FBBA-4FD8-97A6-B0014FA5065D@oracle.com> <87wp7lvst9.fsf@notabene.neil.brown.name>
To: NeilBrown <neilb@suse.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 6, 2017, at 11:17 PM, NeilBrown <neilb@suse.com> wrote:
> 
> On Fri, Jun 30 2017, Chuck Lever wrote:
>> 
>> Wouldn't it be nicer if it worked like this:
>> 
>> (guest)$ cat /etc/hosts
>> 129.0.0.2  localhyper
>> (guest)$ mount.nfs localhyper:/export /mnt
>> 
>> And the result was a working NFS mount of the
>> local hypervisor, using whatever NFS version the
>> two both support, with no changes needed to the
>> NFS implementation or the understanding of the
>> system administrator?
> 
> Yes. Yes. Definitely Yes.
> Though I suspect you mean "127.0.0.2", not "129..."??

I meant 129.x.  127.0.0 has well-defined semantics as a
loopback to the same host. The hypervisor is clearly a
network entity that is distinct from the local host.

But maybe you could set up 127.0.0.2, .3 for this purpose?
Someone smarter than me could figure out what is best to
use here. I'm not familiar with all the rules for loopback
and link-local IPv4 addressing.

Loopback is the correct analogy, though. It has predictable
host numbers that can be known in advance, and loopback
networking is set up automatically on a host, without the
need for a physical network interface. These are the stated
goals for vsock.

The benefit for re-using loopback here is that every
application that can speak AF_INET can already use it. For
NFS that means all the traditional features work: rpcbind,
NFSv4.0 callback, IP-based share access control, and Kerberos,
and especially DNS so that you can mount by hostname.


> There must be some way to redirect TCP connections to some address
> transparently through to the vsock protocol.
> The "sshuttle" program does this to transparently forward TCP connections
> over an ssh connection.  Using a similar technique to forward
> connections over vsock shouldn't be hard.
> 
> Or is performance really critical, and you get too much copying when you
> try forwarding connections?  I suspect that is fixable, but it would be
> a little less straight forward.
> 
> I would really *not* like to see vsock support being bolted into one
> network tool after another.


--
Chuck Lever



