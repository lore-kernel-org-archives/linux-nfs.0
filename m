From: Jeff Hanson <jhansonxi@gmail.com>
Subject: Re: NFS and firewalls
Date: Mon, 27 Dec 2010 21:58:49 -0500
Message-ID: <AANLkTimqwRzCWBSb8yFjbq2pHrXvGKuDqM1SGvwMiA+-@mail.gmail.com>
References: <AANLkTi=67a4C7Wx1zhoB-gAV_uXyzizenLmaEnbruy9i@mail.gmail.com>
	<1293495170.9774.7.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux NFS <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:65327 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753054Ab0L1C6u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Dec 2010 21:58:50 -0500
Received: by gwj20 with SMTP id 20so4661985gwj.19
        for <linux-nfs@vger.kernel.org>; Mon, 27 Dec 2010 18:58:49 -0800 (PST)
In-Reply-To: <1293495170.9774.7.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 27, 2010 at 7:12 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> NFSv4.1 fully solves this problem. All connections to the server are
> initiated by the client, including for callback paths. The only port
> that needs to be accessible on the server side is port 2049.
>
> NFSv4 also solves the problem, with the one caveat that callbacks won't
> work behind a NAT (which basically means you won't get delegations).
>

Thanks.  I made a note in the Ubuntu bug report.
