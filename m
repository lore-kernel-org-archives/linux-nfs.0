Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f46.google.com ([209.85.213.46]:41948 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233AbaJTWbS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Oct 2014 18:31:18 -0400
Received: by mail-yh0-f46.google.com with SMTP id f73so2767yha.19
        for <linux-nfs@vger.kernel.org>; Mon, 20 Oct 2014 15:31:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <D259448C-9E9B-43AE-A809-A73C3C2716C5@oracle.com>
References: <20141016192919.13414.3151.stgit@manet.1015granger.net>
	<20141016194000.13414.83844.stgit@manet.1015granger.net>
	<54454762.8020506@Netapp.com>
	<A1CBA20C-FA2F-4E6B-9D94-75F7EFDED9C3@oracle.com>
	<CAHQdGtTgJ7vRR3Kw8n4K4=PSoMXV_ZQK9yFkAcK-CK5xsaTm3A@mail.gmail.com>
	<D259448C-9E9B-43AE-A809-A73C3C2716C5@oracle.com>
Date: Tue, 21 Oct 2014 01:31:17 +0300
Message-ID: <CAHQdGtRahOX68j6J6Vq9ykBE-2qUm1sd_HPw=HGimKAGs5V=9Q@mail.gmail.com>
Subject: Re: [PATCH v1 13/16] NFS: Add sidecar RPC client support
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Tom Talpey <tom@talpey.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 20, 2014 at 11:11 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> Hi Trond-
>
> On Oct 20, 2014, at 3:40 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>
>> Why aren't we doing the callbacks via RDMA as per the recommendation
>> in RFC5667 section 5.1?
>
> There’s no benefit to it. With a side car, the server requires
> few or no changes. There are no CB operations that benefit
> from using RDMA. It’s very quick to implement, re-using most of
> the client backchannel implementation that already exists.
>
> I’ve discussed this with an author of RFC 5667 [cc’d], and also
> with the implementors of an existing NFSv4.1 server that supports
> RDMA. They both agree that a side car is an acceptable, or even a
> preferable, way to approach backchannel support.
>
> Also, when I discussed this with you months ago, you also felt
> that a side car was better than adding backchannel support to the
> xprtrdma transport. I took this approach only because you OK’d it.
>
> But I don’t see an explicit recommendation in section 5.1. Which
> text are you referring to?

The very first paragraph argues that because callback messages don't
carry bulk data, there is no problem with using RPC/RDMA and, in
particular, with using RDMA_MSG provided that the buffer sizes are
negotiated correctly.

So the questions are:

1) Where is the discussion of the merits for and against adding
bi-directional support to the xprtrdma layer in Linux? What is the
showstopper preventing implementation of a design based around
RFC5667?

2) Why do we instead have to solve the whole backchannel problem in
the NFSv4.1 layer, and where is the discussion of the merits for and
against that particular solution? As far as I can tell, it imposes at
least 2 extra requirements:
 a) NFSv4.1 client+server must have support either for session
trunking or for clientid trunking
 b) NFSv4.1 client must be able to set up a TCP connection to the
server (that can be session/clientid trunked with the existing RDMA
channel)

All I've found so far on googling these questions is a 5 1/2 year old
email exchange between Tom Tucker and Ricardo where the conclusion
appears to be that we can, in time, implement both designs. However
there is no explanation of why we would want to do so.
http://comments.gmane.org/gmane.linux.nfs/22927

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
