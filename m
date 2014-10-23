Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:51122 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850AbaJWNzm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Oct 2014 09:55:42 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v1 13/16] NFS: Add sidecar RPC client support
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20141023133229.GA16717@fieldses.org>
Date: Thu, 23 Oct 2014 09:55:28 -0400
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Tom Talpey <tom@talpey.com>
Message-Id: <D826C6DC-A3BB-4AD8-AD45-934BA6F11D1A@oracle.com>
References: <20141016192919.13414.3151.stgit@manet.1015granger.net> <20141016194000.13414.83844.stgit@manet.1015granger.net> <54454762.8020506@Netapp.com> <A1CBA20C-FA2F-4E6B-9D94-75F7EFDED9C3@oracle.com> <CAHQdGtTgJ7vRR3Kw8n4K4=PSoMXV_ZQK9yFkAcK-CK5xsaTm3A@mail.gmail.com> <D259448C-9E9B-43AE-A809-A73C3C2716C5@oracle.com> <CAHQdGtRahOX68j6J6Vq9ykBE-2qUm1sd_HPw=HGimKAGs5V=9Q@mail.gmail.com> <5BF0312C-06EC-4D83-81E9-F929724A0EAD@oracle.com> <CAHQdGtRumr9Cr6oJPUEw5nLiiWqNW5JRq7tzpsKUVtCG=F1QFg@mail.gmail.com> <EB7360E0-CDE8-40A6-8F91-6A119EE68DEC@oracle.com> <20141023133229.GA16717@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 23, 2014, at 9:32 AM, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Tue, Oct 21, 2014 at 01:11:26PM -0400, Chuck Lever wrote:
>> The size of the changeset _is_ the justification. It’s
>> a much less invasive change to add a TCP side-car than
>> it is to implement RDMA backchannel on both server and
>> client.
> 
> Something I'm confused about: is bidirectional RPC/RDMA optional or
> mandatory for servers to implement?

IMO bi-directional RPC/RDMA is not required anywhere in RFCs 5666
(the RPC/RDMA spec) or 5667 (the NFS on RPC/RDMA spec).

> Something somewhere has to be mandatory if we want to guarantee a
> working backchannel between any two implementations.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



