Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:36747 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750925Ab1KGIDu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Nov 2011 03:03:50 -0500
Message-ID: <4EB790AB.8070909@parallels.com>
Date: Mon, 07 Nov 2011 12:02:51 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH v3 0/3] SUNRPC: rcbind clients virtualization
References: <20111027180824.20459.23219.stgit@localhost6.localdomain6> <20111027202514.GA31669@fieldses.org> <4EAA74DD.3070708@parallels.com> <20111028093036.GA2604@fieldses.org> <4EAA78DD.2000408@parallels.com> <20111104221045.GL721@fieldses.org>
In-Reply-To: <20111104221045.GL721@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

05.11.2011 02:10, J. Bruce Fields пишет:
>> BTW, Bruce, please, have a brief look at my e-mail to
>> linux-nfs@vger.kernel.org named "SUNRPC: non-exclusive pipe
>> creation".
>> I've done a lot in "RPC pipefs per net ns" task, and going to send
>> first patches soon. But right now I'm really confused will this
>> non-exclusive pipes creation and almost ready so remove this
>> functionality. But I'm afraid, that I've missed something. Would be
>> greatly appreciate for your opinion about my question.
>
> Sorry for the delay--it looks reasonable to me on a quick skim, but I'm
> assuming it's Trond that will need to review this.
>

Thanks for your review.
And, yep, still waiting for Trond answer too...

-- 
Best regards,
Stanislav Kinsbursky
