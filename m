Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:51135 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751688AbaJTULd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Oct 2014 16:11:33 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v1 13/16] NFS: Add sidecar RPC client support
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAHQdGtTgJ7vRR3Kw8n4K4=PSoMXV_ZQK9yFkAcK-CK5xsaTm3A@mail.gmail.com>
Date: Mon, 20 Oct 2014 16:11:25 -0400
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Tom Talpey <tom@talpey.com>
Message-Id: <D259448C-9E9B-43AE-A809-A73C3C2716C5@oracle.com>
References: <20141016192919.13414.3151.stgit@manet.1015granger.net> <20141016194000.13414.83844.stgit@manet.1015granger.net> <54454762.8020506@Netapp.com> <A1CBA20C-FA2F-4E6B-9D94-75F7EFDED9C3@oracle.com> <CAHQdGtTgJ7vRR3Kw8n4K4=PSoMXV_ZQK9yFkAcK-CK5xsaTm3A@mail.gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

On Oct 20, 2014, at 3:40 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> Why aren't we doing the callbacks via RDMA as per the recommendation
> in RFC5667 section 5.1?

There’s no benefit to it. With a side car, the server requires
few or no changes. There are no CB operations that benefit
from using RDMA. It’s very quick to implement, re-using most of
the client backchannel implementation that already exists.

I’ve discussed this with an author of RFC 5667 [cc’d], and also
with the implementors of an existing NFSv4.1 server that supports
RDMA. They both agree that a side car is an acceptable, or even a
preferable, way to approach backchannel support.

Also, when I discussed this with you months ago, you also felt
that a side car was better than adding backchannel support to the
xprtrdma transport. I took this approach only because you OK’d it.

But I don’t see an explicit recommendation in section 5.1. Which
text are you referring to?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



