Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:60477 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753351Ab1GIQec (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Jul 2011 12:34:32 -0400
Message-ID: <4E188315.2040907@candelatech.com>
Date: Sat, 09 Jul 2011 09:34:29 -0700
From: Ben Greear <greearb@candelatech.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC] sunrpc:  Fix race between work-queue and rpc_killall_tasks.
References: <1309992581-25199-1-git-send-email-greearb@candelatech.com> <1309995932.5447.6.camel@lade.trondhjem.org> <4E173BE6.9000005@candelatech.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A198C7C@SACMVEXC2-PRD.hq.netapp.com> <4E177EA8.60109@candelatech.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A198E69@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A198E69@SACMVEXC2-PRD.hq.netapp.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/08/2011 03:14 PM, Myklebust, Trond wrote:

> The calldata gets freed in the rpc_final_put_task() which shouldn't ever be run while the task is still referenced in __rpc_execute

Ok, please go ahead and use your patch for the killall tasks race.  My problem remains with or without
your patch, and with or without my version.  So, I'm hitting something else.

I'm real low on ideas of how exactly I am hitting the bug..but will keep poking around.

Thanks,
Ben

>
> IOW: it should be impossible to call rpc_exit_task() after rpc_final_put_task
> N�����r��y���b�X��ǧv�^�)޺{.n�+����{���"��^n�r��z���h����&���G���h�(�階�ݢj"���m�����z�ޖ���f���h���~�mml==


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
