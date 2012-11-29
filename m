Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:53669 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752029Ab2K2NES convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2012 08:04:18 -0500
Message-ID: <50B75D42.4030802@parallels.com>
Date: Thu, 29 Nov 2012 17:04:02 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>
Subject: Re: NFSd in container - it works
References: <50B64628.4070007@parallels.com> <20121128200126.GA17875@fieldses.org> <20121128152813.2b4c388d@tlielax.poochiereds.net> <50B74CCB.9080000@parallels.com> <20121129071309.6550614e@tlielax.poochiereds.net> <50B759AB.6010504@parallels.com> <20121129075508.6f6f1c76@tlielax.poochiereds.net>
In-Reply-To: <20121129075508.6f6f1c76@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

29.11.2012 16:55, Jeff Layton пишет:
>
> nfsdcld is being ripped out in 3.10. The binaries for it are already
> gone from nfs-utils. If you disable the legacy and usermode helper
> trackers, then you have nothing left. :)
>

I was going to disable only usermode helper in container for a while (it looks like we have at least half a year till 3.10 kernel).

> I think you'll need to come up with some mechanism to ensure that these
> things are done in the correct container. What that is, and how that
> should work, I'm not sure...
>

This doesn't look that complicated: root have to be taken from task, which starts tracker and stored with NFSd per-net data.
Then it can be passed to usermode helper. And of course, this path have to be grabbed (path_get() must be called).
Not a great design. But it will work, I believe. And doesn't need any changes to other parts of kernel tree...

-- 
Best regards,
Stanislav Kinsbursky
