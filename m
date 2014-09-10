Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f170.google.com ([209.85.220.170]:40547 "EHLO
	mail-vc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038AbaIJGrM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Sep 2014 02:47:12 -0400
Received: by mail-vc0-f170.google.com with SMTP id hy4so3463258vcb.15
        for <linux-nfs@vger.kernel.org>; Tue, 09 Sep 2014 23:47:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <82E7C9A01FD0764CACDD35D10F5DFB6E72376E@001FSN2MPN1-044.001f.mgd2.msft.net>
References: <CALXu0Ue9z-xbFk9hhsvu4c38qqmd0Wwupk2LvL99rwoAcRMqOw@mail.gmail.com>
	<540831FE.1010208@rug.nl>
	<CALXu0Ufa166-PocKOOMBSF6yONaMxyUMHQmLA8NuSda9sE8PVQ@mail.gmail.com>
	<54085BF3.60802@rug.nl>
	<1409855758.8703.48.camel@willson.usersys.redhat.com>
	<CALXu0UeX=KRD949z8QX0-XoHQucP5X=0ERmTdMrSxSjQFJatsQ@mail.gmail.com>
	<82E7C9A01FD0764CACDD35D10F5DFB6E72376E@001FSN2MPN1-044.001f.mgd2.msft.net>
Date: Tue, 9 Sep 2014 23:47:11 -0700
Message-ID: <CAHQdGtRjOM8uxAjvxshh+VLykgJPy8BSb2AB7d2XRzz4NzmgTg@mail.gmail.com>
Subject: Re: How to use NFS with multiple principals in different realms?
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "Nordgren, Bryce L -FS" <bnordgren@fs.fed.us>
Cc: Cedric Blancher <cedric.blancher@gmail.com>, Simo Sorce <simo@redhat.com>,
        Steve Dickson <steved@redhat.com>, Jurjen Bokma <j.bokma@rug.nl>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "<kerberos@mit.edu>" <kerberos@mit.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 9, 2014 at 7:18 PM, Nordgren, Bryce L -FS
<bnordgren@fs.fed.us> wrote:
>
>> Per Oracle support this is not quite correct: if you have multiple tickets in a
>> DIR: then the NFS client is either required to negotiate with the server (RFC
>> 3530) or try the credentials in order until one works.
>
> "negotiate" appears to mean select a security mechanism, such as Kerberos vs. something else. Is there actually an "intra-mechanism" requirement?
>
>> Still it has to try all options, i.e. negotiate. This is what the reference
>> implementation for NFS (Solaris) does.

Is it time to party like it's 1999? Who listed Solaris as the
functional reference for the Linux rpc.gssd daemon while I wasn't
looking?

rpc.gssd and its intended user functionality is listed in its manpage.

Feel free to put in a feature request if you think that new
functionality is needed to support a good use case that you may have,
but please don't try to pass it off as a protocol requirement that
we're not fulfilling unless you are prepared to point to chapter and
verse of the relevant RFC. A quick grep will show you that there is
nothing in RFC3530 that even mentions kerberos tickets, let alone
describes how they are to be managed if you have more than one.
Neither does RFC2623.

> What are "all the options"? It could try nfs/fqdn@REALM for each REALM present in your ticket cache. It could maintain a separate list of realms not in your cache to be tried. It could let the user specify a principal to try. This has nothing to do with client/server communication and more with probing the Kerberos trust network to see if there is a path to walk from one of the credentials in your cache to one of the potential service principals.
>
> I think what you're saying is that after the negotiation has settled on Kerberos, you want more aggressive probing.
>
> Alternatively, in lieu of aggressive probing (which would yield shared Kerberos user principal trustable by both client and server), you want the id mapper on the NFS client and on the NFS server to map the same NFS id to different Kerberos principals. And then the client system should also know what Kerberos principal the server system has mapped to the relevant NFS ID (server-wide? For a particular mount point?). And both client-recognized and server-recognized Kerberos principals must be in the user's cache. And trust that the two principals are the same ultimately stems from the fact that they're in the same user's Kerberos cache, which is presumably under the control of one human. But I think there still has to be a trust path from NFS client to NFS server. Or no?
>
> Do NFS ID mappers talk to one another?  How would they negotiate? I think I need a picture to nail down all the moving parts.

RFC3530 does not describe any form of NFS id mapper negotiation. That
lies entirely outside the scope of the protocol, and is usually
ensured by deploying third party solutions such as LDAP.

In the NFSv4 spec,  the client just asserts a "owner@dns_domain" or
"owner_group@dns_domain" string as part of a SETATTR command to set an
ACL or a file owner/owner_group, and either the server recognises it
or it doesn't. If the server doesn't recognise the string, then it
returns an error, and the acl/ownership change is not allowed.

On the other hand, the client accepts whatever owner@domain or
owner_group@domain strings the server returns as part of a GETATTR or
READDIR command to retrieve an ACL or file owner/owner_group. If the
client doesn't have a mapping, then it will usually try to represent
the string as an anonymous user/owner so that it can at least list
something that the application can recognise.

Either way, the client isn't allowed to use any of that idmapping
information for file access or other security enforcement tasks. Such
enforcement decisions are rather done through RPC calls directly to
the server, and that may be authenticated by an RPCSEC_GSS session.
E.g. if the client is trying to decide if it should allow a process
access to the cached data for a given file, then it should send an
ACCESS rpc call to the server. It will never try to read the ACL
directly and interpret that. If the client wants to know if a process
is allowed to create a directory, it sends an RPC call that attempts
the operation.

IOW: the NFSv4 protocol limits the scope of the problem by trying to
be robust against relying on idmapping for security purposes, but
limiting the functionality available to applications if your client
and server don't have a way to share idmapping information (ability to
set/read/modify acls, or to change file ownership).

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
