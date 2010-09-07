Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from python-06.easyrencontre.com ([91.199.255.56]:60568 "EHLO
	mail.easyflirt.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751472Ab0IGG73 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 02:59:29 -0400
Received: from [127.0.0.1] (office.easyrencontre.com [78.155.152.6])
	by mail.easyflirt.com (Postfix) with ESMTPSA id 90F206374D4
	for <linux-nfs@vger.kernel.org>; Tue,  7 Sep 2010 08:59:27 +0200 (CEST)
Message-ID: <4C85E2CD.9060508@duchatelet.net>
Date: Tue, 07 Sep 2010 08:59:25 +0200
From: Greg <greg-sys@duchatelet.net>
To: linux-nfs@vger.kernel.org
Subject: Re: Relocate NFS root FS for maintenance
References: <4C7E4469.70807@duchatelet.net> <4C7ECB23.60300@excfb.com> <4C7F5302.30300@duchatelet.net> <20100902160627.GH13117@fieldses.org>
In-Reply-To: <20100902160627.GH13117@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

  Le 02/09/2010 18:06, J. Bruce Fields a écrit :
> I think I just don't understand your setup, because I'm confused about
> what you're asking for.  (If the thing you're upgrading is literally the
> only path between the nfs servers and their storage, then what can we
> do?)

The setup:
clients (apache) ---> server1 nfs4 --> SAN storage via iscsi

I want to do a firmware upgrade on the SAN without stopping the NFS 
server, cause Apache will wait for IO and reach the limits in 2 
seconds... then never die, I have to reboot all clients servers.

A trick could be to relocate the export to an empty real partition on 
the NFS server, so clients could access the share but not the datas. 
Apache will not complain, just answer with 404 Not Found errors :)

-- 
Greg

