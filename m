Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:52294 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752575Ab3CFGTh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Mar 2013 01:19:37 -0500
Message-ID: <5136DFBE.3090505@parallels.com>
Date: Wed, 6 Mar 2013 10:18:38 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>, <Trond.Myklebust@netapp.com>,
        <linux-kernel@vger.kernel.org>, <devel@openvz.org>
Subject: Re: [Devel] [PATCH] nfsd: check client tracker initialization result
References: <20130228120959.6764.17787.stgit@localhost.localdomain> <20130305212001.GD15816@fieldses.org> <5136CEEB.5090505@parallels.com>
In-Reply-To: <5136CEEB.5090505@parallels.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

06.03.2013 09:06, Stanislav Kinsbursky пишет:
> 06.03.2013 01:20, J. Bruce Fields пишет:
>> On Thu, Feb 28, 2013 at 03:09:59PM +0300, Stanislav Kinsbursky wrote:
>>> Function nfsd4_client_tracking_init() can return error.
>>
>> Before, I think that we the nfsd4_client_* functions just became no-ops
>> in this case.  With the result that no client records get written, and
>> so clients are unable to reclaim on the next boot.
>>
>> Which is annoying, but possibly not as annoying as your server
>> completely refusing to start.
>>
>> It's arguably more helpful in the long run to fail immediately when we
>> recognize reboot recovery isn't going to work.  But in practice this may
>> mean people that never knew they had a problem suddenly have servers
>> that don't start at all.
>>
>> So I'm inclined to be more forgiving and leave this as it is.  But maybe
>> something like a warning printk would be appropriate.
>>
>
> Ok then.
> I'll add the warning anf convert the function to be "void" rather then "int".
> Thanks!
>

We already have a warning.
So, probably all we need is just to change a prototype to make it less confusing.
Is it ok?

-- 
Best regards,
Stanislav Kinsbursky
