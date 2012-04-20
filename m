Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:56491 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751551Ab2DTGFI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Apr 2012 02:05:08 -0400
Message-ID: <4F90FC91.9090805@parallels.com>
Date: Fri, 20 Apr 2012 10:05:05 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH] SUNRPC: skip dead but not buried clients on PipeFS events
References: <20120419105707.32131.79719.stgit@localhost6.localdomain6> <4F8FF8D9.5080503@parallels.com> <20120419214043.GA23309@fieldses.org>
In-Reply-To: <20120419214043.GA23309@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

20.04.2012 01:40, bfields@fieldses.org написал:
> On Thu, Apr 19, 2012 at 03:36:57PM +0400, Stanislav Kinsbursky wrote:
>> Sorry, but ignore this patch too.
>> It can't be that simple because of these cl_count tricks in rpc_release_client...
> OK.  Very minor whine:
>
>> 19.04.2012 14:57, Stanislav Kinsbursky пишет:
>>> These clients can't be safely dereferenced if their counter in 0.
>>>
>>> Signee-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>>>
>>> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
> I don't mind fixing up trivial slips every now and then, but that double
> signed-off-by seems to happen on a lot of your posts; could you figure
> out what's up with your scripts?

Yes, sure. Sorry.
I've noticed this problem just yesterday.
