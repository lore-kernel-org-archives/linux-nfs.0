Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:45103 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752005Ab0DZNE2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Apr 2010 09:04:28 -0400
Date: Mon, 26 Apr 2010 15:04:26 +0200 (CEST)
From: Jan Engelhardt <jengelh@medozas.de>
To: Manio <manio@skyboo.net>
cc: linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: NFS mount attempts hangs with btrfs on server side
In-Reply-To: <4BCED584.5000305@skyboo.net>
Message-ID: <alpine.LSU.2.01.1004261500210.9302@obet.zrqbmnf.qr>
References: <4BCA15A7.9000502@skyboo.net> <4BCED28B.5040806@skyboo.net> <alpine.LSU.2.01.1004211227280.28393@obet.zrqbmnf.qr> <4BCED584.5000305@skyboo.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Wednesday 2010-04-21 12:37, Manio wrote:
> On 2010-04-21 12:29, Jan Engelhardt wrote:
>> I'd rather have a real description rather than "stuff like that".
>> Since I am not on debian, "old nfs-utils" would not happen -
>> rpcbind-0.1.6+git20080930 and nfs-kernel-server-1.1.3
>> should be very much recent enough.
>> Especially since exportability of filesystems is usually not
>> so much a userspace thing.
>
> Unfortunatelly i can't tell you which package exactly was causing the problem.

So I bisected it then.

commit 3a340251597a5b0c579c31d8caf9aa3b53a77016
Author: David Woodhouse <David.Woodhouse@intel.com>
Date:   Thu Aug 28 11:05:17 2008 -0400

    Use fsid from statfs for UUID if blkid can't cope (or not used)
    
    Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

It is the commit enabling btrfs mounts. The message hints to blkid
being unable to get the uuid or something, however, the standalone
/sbin/blkid tool does get a uuid:

/dev/loop2: UUID="e19fe89b-cde3-4ccc-bc70-b759a57bd1c9"
UUID_SUB="f29c6218-d040-4546-a227-4dd2d2142817" TYPE="btrfs" 

So what went wrong here?
