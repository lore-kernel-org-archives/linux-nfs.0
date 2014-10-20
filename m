Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f173.google.com ([209.85.220.173]:65122 "EHLO
	mail-vc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180AbaJTTkM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Oct 2014 15:40:12 -0400
Received: by mail-vc0-f173.google.com with SMTP id ij19so4130542vcb.18
        for <linux-nfs@vger.kernel.org>; Mon, 20 Oct 2014 12:40:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <A1CBA20C-FA2F-4E6B-9D94-75F7EFDED9C3@oracle.com>
References: <20141016192919.13414.3151.stgit@manet.1015granger.net>
	<20141016194000.13414.83844.stgit@manet.1015granger.net>
	<54454762.8020506@Netapp.com>
	<A1CBA20C-FA2F-4E6B-9D94-75F7EFDED9C3@oracle.com>
Date: Mon, 20 Oct 2014 22:40:11 +0300
Message-ID: <CAHQdGtTgJ7vRR3Kw8n4K4=PSoMXV_ZQK9yFkAcK-CK5xsaTm3A@mail.gmail.com>
Subject: Re: [PATCH v1 13/16] NFS: Add sidecar RPC client support
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 20, 2014 at 9:09 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
>
> On Oct 20, 2014, at 1:33 PM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
>
> > On 10/16/14 15:40, Chuck Lever wrote:
> >> So far, TCP is the only transport that supports bi-directional RPC.
> >>
> >> When mounting with NFSv4.1 using a transport that does not support
> >> bi-directional RPC, establish a TCP sidecar connection to handle
> >> backchannel traffic for a session. The sidecar transport does not
> >> use its forward channel except for sending BIND_CONN_TO_SESSION
> >> operations.
> >>
> >> This commit adds logic to create and destroy the sidecar transport.
> >> Subsequent commits add logic to use the transport.
> >
> > I thought NFS v4.0 also uses a separate connection for the backchannel?
>
> For NFSv4.0, the server opens a connection to the client. For
> NFSv4.1, the client opens the side car connection to the
> server, and then performs BIND_CONN_TO_SESSION, an operation
> not in NFSv4.0. The processes are not terribly similar.
>
> > Can any of that code be reused here, rather than creating new sidecar structures?
>
> Since it’s the client opening a connection in this case,
> I don’t see any obvious common code paths that I haven’t
> already re-used. I’m open to suggestions.

Why aren't we doing the callbacks via RDMA as per the recommendation
in RFC5667 section 5.1?

-- 

Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
