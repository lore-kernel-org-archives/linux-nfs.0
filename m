Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51430 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750901AbaJWNcf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Oct 2014 09:32:35 -0400
Date: Thu, 23 Oct 2014 09:32:29 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Tom Talpey <tom@talpey.com>
Subject: Re: [PATCH v1 13/16] NFS: Add sidecar RPC client support
Message-ID: <20141023133229.GA16717@fieldses.org>
References: <20141016192919.13414.3151.stgit@manet.1015granger.net>
 <20141016194000.13414.83844.stgit@manet.1015granger.net>
 <54454762.8020506@Netapp.com>
 <A1CBA20C-FA2F-4E6B-9D94-75F7EFDED9C3@oracle.com>
 <CAHQdGtTgJ7vRR3Kw8n4K4=PSoMXV_ZQK9yFkAcK-CK5xsaTm3A@mail.gmail.com>
 <D259448C-9E9B-43AE-A809-A73C3C2716C5@oracle.com>
 <CAHQdGtRahOX68j6J6Vq9ykBE-2qUm1sd_HPw=HGimKAGs5V=9Q@mail.gmail.com>
 <5BF0312C-06EC-4D83-81E9-F929724A0EAD@oracle.com>
 <CAHQdGtRumr9Cr6oJPUEw5nLiiWqNW5JRq7tzpsKUVtCG=F1QFg@mail.gmail.com>
 <EB7360E0-CDE8-40A6-8F91-6A119EE68DEC@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <EB7360E0-CDE8-40A6-8F91-6A119EE68DEC@oracle.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 21, 2014 at 01:11:26PM -0400, Chuck Lever wrote:
> The size of the changeset _is_ the justification. It’s
> a much less invasive change to add a TCP side-car than
> it is to implement RDMA backchannel on both server and
> client.

Something I'm confused about: is bidirectional RPC/RDMA optional or
mandatory for servers to implement?

Something somewhere has to be mandatory if we want to guarantee a
working backchannel between any two implementations.

--b.
