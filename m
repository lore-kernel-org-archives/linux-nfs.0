Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49545 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756325AbbCFQti (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Mar 2015 11:49:38 -0500
Message-ID: <54F9DA9D.8010106@RedHat.com>
Date: Fri, 06 Mar 2015 11:49:33 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Martin Pitt <martin.pitt@ubuntu.com>, linux-nfs@vger.kernel.org
CC: Steve Langasek <steve.langasek@ubuntu.com>,
        systemd-devel@lists.freedesktop.org
Subject: Re: [PATCH 0/1] details for starting nfs-idmapd also on clients
References: <1425640544-24230-1-git-send-email-martin.pitt@ubuntu.com>
In-Reply-To: <1425640544-24230-1-git-send-email-martin.pitt@ubuntu.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On 03/06/2015 06:15 AM, Martin Pitt wrote:
> Hello all,
> 
> Steve Langasek pointed out in [1] that idmapd is also necessary on the client
> side. It isn't for my very simple NFSv4 test, but then again I don't know that
> much about the various other modes of operation.
> 
> This patch starts nfs-idmapd.service on clients too.
This is distro specific... Other distros use the 
key ring based nfsidmap(5) command to do the id mapping.

Make note, with new kernels the default upcall is to the
nfsdimap command, if that fails then the rpc.idmapd daemon 
is tried. Meaning there are two upcalls for every id map
when rpc.idmapd is used. This was the reason for the switch.

steved.
