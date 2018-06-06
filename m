Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:51026 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752059AbeFFPsV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jun 2018 11:48:21 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [PATCH v1 2/2] NFSv4.0: Remove transport protocol name from
 non-UCS client ID
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <d14af3599d007587137eb6814baa98b91ff3efc8.camel@hammerspace.com>
Date: Wed, 6 Jun 2018 11:48:14 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <73D2F6EC-8CE6-4290-9713-6D5B8B0DC2E3@oracle.com>
References: <20180604144154.11877.19298.stgit@manet.1015granger.net>
 <20180604145334.11877.12862.stgit@manet.1015granger.net>
 <d14af3599d007587137eb6814baa98b91ff3efc8.camel@hammerspace.com>
To: Trond Myklebust <trondmy@hammerspace.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jun 6, 2018, at 11:44 AM, Trond Myklebust <trondmy@hammerspace.com> =
wrote:
>=20
> On Mon, 2018-06-04 at 10:53 -0400, Chuck Lever wrote:
>> Commit 69dd716c5ffd ("NFSv4: Add socket proto argument to
>> setclientid") (2007) added the transport protocol name to the client
>> ID string, but the patch description doesn't explain why this was
>> necessary.
>>=20
>> At that time, the only transport protocol name that would have been
>> used is "tcp" (for both IPv4 and IPv6), resulting in no additional
>> distinctiveness of the client ID string.
>>=20
>> Since there is one client instance, the server should recognize it's
>> state whether the client is connecting via TCP or RDMA. Same client,
>> same lease.
>=20
> The reason why this is the case now is because the trunking code
> overrides the guardrails in nfs_get_client(). The latter does match on
> the protocol.

OK. Would that also true in the UCS case?


--
Chuck Lever



