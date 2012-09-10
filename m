Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:54075 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752470Ab2IJPzg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Sep 2012 11:55:36 -0400
Message-ID: <504E0D76.5060905@parallels.com>
Date: Mon, 10 Sep 2012 19:55:34 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Jeff Layton <jlayton@redhat.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH v2] SUNRPC: check current nsproxy before set of node name
 on client creation
References: <20120813113731.9629.31906.stgit@localhost.localdomain>     <20120813081054.0ee39037@corrin.poochiereds.net>    <4FA345DA4F4AE44899BD2B03EEEC2FA908F90888@SACEXCMBX04-PRD.hq.netapp.com>    <504ADED9.2020607@parallels.com>   <4FA345DA4F4AE44899BD2B03EEEC2FA908F914D4@SACEXCMBX04-PRD.hq.netapp.com>   <504DA833.60301@parallels.com>  <4FA345DA4F4AE44899BD2B03EEEC2FA908F9547B@SACEXCMBX04-PRD.hq.netapp.com>  <504E0930.5050408@parallels.com> <4FA345DA4F4AE44899BD2B03EEEC2FA908F96556@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA908F96556@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

10.09.2012 19:41, Myklebust, Trond пишет:
> On Mon, 2012-09-10 at 19:37 +0400, Stanislav Kinsbursky wrote:
>> Hi, Trond.
>> So, if I understand you right, we can create rpc client (or increase usage
>> counter) on NSMPROC_MON call and destroy (or decrease usage counter) on
>> NSMPROC_UNMON call.
>> Will this solution works?
>
> The rpc client(s) will need to be per-net-namespace, which complicates
> matters a little bit, but yes, creation at NSMPROC_MON, and destruction
> at NSMPROC_UNMON should work.
>

Not really. We already have per-net Lockd data. So, adding one more 
reference-counted rpc client doesn't look that complicated.
Ok, thanks. I'll try to implement this.

-- 
Best regards,
Stanislav Kinsbursky
