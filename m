From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH] mount: enable retry for nfs23 to set the correct protocol for mount.
Date: Mon, 21 Jul 2008 15:01:17 -0400
Message-ID: <76bd70e30807211201v749d1ca4tc5f9c16721ef9336@mail.gmail.com>
References: <18556.40594.897682.204554@notabene.brown>
	 <18559.53893.95829.499988@notabene.brown>
	 <76bd70e30807190909n12b9f70an87ccb62198c3a7d@mail.gmail.com>
	 <18562.57287.656749.540603@notabene.brown>
	 <76bd70e30807201828t70d5b1d0m4c242c5c8864c3bb@mail.gmail.com>
	 <18563.63821.501053.402741@notabene.brown>
	 <76bd70e30807202143q51820814n5a5a0bc0976f9763@mail.gmail.com>
	 <18564.10115.809293.243948@notabene.brown>
	 <76bd70e30807210832l188bd3adl92762d5856bbaa5e@mail.gmail.com>
	 <1216662027.7649.15.camel@localhost>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Neil Brown" <neilb@suse.de>, "Steve Dickson" <SteveD@redhat.com>,
	linux-nfs@vger.kernel.org
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"Trond Myklebust" <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:35454 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753962AbYGUTBU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2008 15:01:20 -0400
Received: by nf-out-0910.google.com with SMTP id d3so528798nfc.21
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2008 12:01:18 -0700 (PDT)
In-Reply-To: <1216662027.7649.15.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 21, 2008 at 1:40 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Mon, 2008-07-21 at 11:32 -0400, Chuck Lever wrote:
>
>> I will have to look at it again.  My version of this fix, at least,
>> made the kernel use TCP for mountd and NFS if "proto=tcp" is
>> specified, UDP for both if "proto=udp" is specified, and TCP for NFS
>> and UDP for mountd if none were specified.  This is exactly how the
>> legacy mount command starts off.
>>
>> If Trond's version of the fix doesn't do that, then that is a behavior
>> regression.
>
> A regression w.r.t. what, exactly?
>
> In the binary mount case, we certainly _always_ used TCP to talk to
> mountd, when specifying NFS-over-TCP.

That's correct, but it's not what I was referring to above.

> I don't remember seeing a public discussion as to why we should change
> the default to using UDP when talking to mountd for the NFS-over-TCP
> case, or even whether or not it is a safe to assume that we can. Will
> the text mount retry using mountproto=tcp if mountproto=udp fails? If it
> doesn't, then that would be a regression w.r.t. previously working
> binary setups...

My understanding of the legacy behavior is:

1.  If "proto=tcp" or "tcp" is specified but "mountproto=" is not
specified, then TCP is used for both the mountd request and the NFS
transport

2.  If "proto=udp" or "udp" is specified but "mountproto=" is not
specified, then UDP is used for both the mountd request and the NFS
transport

Explicitly specifying "proto=" usually means the sysadmin has some
kind of transport-specific filtering or firewalling in place; or, in
the TCP case, is attempting to mount a server that is more than
several router hops away and wants a better overall performance for
both NFS and mount requests; or in the UDP case, wants all traffic to
go over UDP (for example, on certain high performance networks where
very small packets like TCP ACKs are very inefficient).  So this is a
shorthand way to get most NFS-related traffic to go over a specific
transport.

In both of these cases, if the server's NFS or mountd service does not
support the requested protocol, the mount request fails outright.

Note that even if "proto=tcp" is specified, certain auxiliary
protocols (like NSM) still use the UDP transport.

[ Before .27, for text-based mounts, "proto=" only controlled the NFS
transport protocol.  The mountd transport protocol always used the
default transport if "mountproto=" was not specified ].

3.  If neither "mountproto=", nor "proto=", nor either "udp" or "tcp"
is specified, then the defaults are used:  UDP is used for mountd and
TCP is used for NFS.

The reason for this is that most common NFS servers support UDP for
mountd, it is less network traffic, and it doesn't leave two extra
ports in TIME_WAIT (one for a TCP rpcbind query to discover the mountd
service's port, and one for a TCP mountd request) after the mountd
request is complete.

[ I think this is reasonable behavior to keep, and I thought that Neil
was suggesting that it no longer works this way in .27-rc.  I'm still
catching up with e-mail so I haven't looked into this yet. ]

If the server doesn't support these transports, the mount.nfs command
will attempt to discover what the server supports and retry the mount
request with the discovered transport options.  If the server doesn't
support any transport supported by the client, or is misconfigured,
the mount request fails.

4.  If "mountproto=" is specified but none of "proto=", "udp" or "tcp"
is specified, then the specified transport is used for the mountd
request, but the default transport (TCP) is used for NFS.

5.  If both "mountproto=" and "proto=" (or "udp" or "tcp") are
specified, then the transport specified by "mountproto=" is used for
the mountd request, and the transport specified by "proto=" (or "udp"
or "tcp") is used for NFS, no matter which order these appear in.

[ This last one was not working properly with text-based mounts prior
to .27 -- if "proto=" appeared after "mountproto=", then in some
cases, "mountproto=" would be overridden. ]

I'm not sure if mount.nfs will try service discovery in these last two
cases, but if it is behaving consistently it should fail such
requests.

6.  If any of "proto=", "udp", "tcp", or "mountproto=" is specified
more than once on the same mount command line, then the value of the
rightmost instance of these options takes effect.

[ And this one was subject to the bug mentioned just above, but should
be fixed in .27. ]

This list would probably be a good addendum to nfs(5).

-- 
Chuck Lever
