Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:15160 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753444Ab2ATQR2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Jan 2012 11:17:28 -0500
Message-ID: <4F199372.7090501@parallels.com>
Date: Fri, 20 Jan 2012 20:16:50 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH 0/2] SUNRPC: make /proc helpers network-namespace-aware
References: <20111206123748.15702.93290.stgit@localhost6.localdomain6>	 <4F19512F.1000903@parallels.com> <20120120143047.GB9877@fieldses.org> <1327070356.23030.0.camel@lade.trondhjem.org>
In-Reply-To: <1327070356.23030.0.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

20.01.2012 18:39, Trond Myklebust пишет:
> On Fri, 2012-01-20 at 09:30 -0500, bfields@fieldses.org wrote:
>> On Fri, Jan 20, 2012 at 03:34:07PM +0400, Stanislav Kinsbursky wrote:
>>> Excuse me, Trond, Bruce, but what about this patch set?
>>> It is not included in Trond's "devel" branch.
>>> Maybe they are in your repo, Bruce?
>>
>> Everything that I had from you is in -rc1 now.
>>
>> --b.
>
> I can carry these patches if you like. They don't seem to conflict with
> anything already in my repository.
>

Yes, would be great. Thank you.

-- 
Best regards,
Stanislav Kinsbursky
