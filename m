Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f180.google.com ([209.85.220.180]:62186 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755864AbaIRUvN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Sep 2014 16:51:13 -0400
Received: by mail-vc0-f180.google.com with SMTP id hq11so1205705vcb.25
        for <linux-nfs@vger.kernel.org>; Thu, 18 Sep 2014 13:51:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <d143828a73125846d583f4c606061109d22869f7.1411068259.git.jbaron@akamai.com>
References: <cover.1411068259.git.jbaron@akamai.com>
	<d143828a73125846d583f4c606061109d22869f7.1411068259.git.jbaron@akamai.com>
Date: Thu, 18 Sep 2014 16:51:12 -0400
Message-ID: <CAHQdGtQOoop=CShDx9dTXSjo47KzWoRqkM9PNx1Si-pFSXg-_w@mail.gmail.com>
Subject: Re: [PATCH 2/2] rpc: Add -EPERM processing for xs_udp_send_request()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jason Baron <jbaron@akamai.com>
Cc: Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 18, 2014 at 3:51 PM, Jason Baron <jbaron@akamai.com> wrote:
> If an iptables drop rule is added for an nfs server, the client can end up in
> a softlockup. Because of the way that xs_sendpages() is structured, the -EPERM
> is ignored since the prior bits of the packet may have been successfully queued
> and thus xs_sendpages() returns a non-zero value. Then, xs_udp_send_request()
> thinks that because some bits were queued it should return -EAGAIN. We then try
> the request and again and a softlockup occurs. The test sequence is simply:
>
> 1) open a file on the nfs server '/nfs/foo' (mounted using udp)
> 2) iptables -A OUTPUT -d <nfs server ip> -j DROP
> 3) write to /nfs/foo
> 4) close /nfs/foo
> 5) iptables -D OUTPUT -d <nfs server ip> -j DROP
>
> The softlockup occurs in step 4 above.

For UDP, the expected and documented behaviour in the case above is as follows:
- if the mount is soft, then return EIO on the first major timeout.
- if the mount is hard, then retry indefinitely on timeout.

Won't these 2 patches end up propagating an EPERM to the application?
That would be a definite violation of both hard and soft semantics.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
