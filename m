Return-Path: linux-nfs-owner@vger.kernel.org
Received: from tuna.sandelman.ca ([209.87.252.184]:58951 "EHLO
	tuna.sandelman.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752762Ab3JVOZu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Oct 2013 10:25:50 -0400
From: Michael Richardson <mcr@sandelman.ca>
To: Ben Greear <greearb@candelatech.com>
cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Getting 'not supported' when trying to mount IPv6 NFS v3 server.
In-Reply-To: <52659D69.1020609@candelatech.com>
References: <52659D69.1020609@candelatech.com>
Date: Tue, 22 Oct 2013 10:19:14 -0400
Message-ID: <357.1382451554@obiwan.sandelman.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Ben Greear <greearb@candelatech.com> wrote:
    > From my own app's logs:

    > # mount -t nfs [4001:1::1:1]:/vol/vol1 /mnt/lf/RDnfse11c0 -o
    > srcaddr=4001:1::1:201,vers=3 # requested NFS version or transport
    > protocol is not supported

    > When this problem happens, I do not see any network traffic when trying
    > to mount.

That sounds like the error that one would get when *mount* was compiled with
the v6-incompatible sunrpc library rather than tirpc.

-- 
]               Never tell me the odds!                 | ipv6 mesh networks [ 
]   Michael Richardson, Sandelman Software Works        | network architect  [ 
]     mcr@sandelman.ca  http://www.sandelman.ca/        |   ruby on rails    [ 
	
