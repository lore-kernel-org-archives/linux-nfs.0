From: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Subject: Re: Error mounting FC8 NFS server with 2.6.31-rc3 NFSv4 client.
Date: Tue, 21 Jul 2009 19:49:51 +0200
Message-ID: <200907211949.52345.elendil@planet.nl>
References: <4A64EB1F.4000602@candelatech.com> <1248178527.5222.0.camel@heimdal.trondhjem.org> <1248178527.5222.0.camel@heimdal.trondhjem.org> <4A65F184.5060802@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Cc: trond.myklebust@fys.uio.no, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from Cpsmtpm-eml108.kpnxchange.com ([195.121.3.12]:61997 "EHLO
	CPSMTPM-EML108.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752259AbZGURtx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jul 2009 13:49:53 -0400
In-reply-To: <4A65F184.5060802@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ben Greear wrote:
> On 07/21/2009 05:15 AM, Trond Myklebust wrote:
>> What does /var/lib/nfs/v4recovery look like on the server?
> 
> The server was misconfigured, but I still think the client should
> behave better in this case.  If you cannot reproduce it, let me know
> and I can try to be more specific.  If you still want the v4recovery
> information, let me know and I'll send it.
> 
> I had my /etc/exports looking like this on the file-server:
> 
> /export/tmp 192.168.100.0/24(rw)
> 
> When I changed it to be:
> /export/tmp 192.168.100.0/24(rw,fsid=0)
> 
> And mounted 192.168.100.6:/ instead of 192.168.100.6:/export/tmp
> then it mounts properly and appears to work just fine.
> 
> If I leave file-server configured properly with fsid=0, but try
> to mount 192.168.100.6:/export/tmp then I get an error about
> no such file or directory, which also appears to be correct
> behaviour.

Duh! I had exactly the same problem this week when I "quickly" set up an 
NFS server on one of my boxes: forgot to add fsid=0 for the NFS4 root. 
Result was the mount hanging on the client and the same errors as Ben 
reported.

It would be great if this configuration problem was detected better.

P.S. /var/lib/nfs/v4recovery on the server was empty in my case.
