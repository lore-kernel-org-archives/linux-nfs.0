Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:58272 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756893Ab2DZS0x convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Apr 2012 14:26:53 -0400
Message-ID: <4F99936B.2050507@parallels.com>
Date: Thu, 26 Apr 2012 22:26:51 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH 2/3] SUNRPC: traverse clients tree on PipeFS event
References: <20120420141419.10848.84280.stgit@localhost6.localdomain6>  <20120420141925.10848.90395.stgit@localhost6.localdomain6> <1335463902.9701.35.camel@lade.trondhjem.org>
In-Reply-To: <1335463902.9701.35.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

26.04.2012 22:11, Myklebust, Trond написал:
> On Fri, 2012-04-20 at 18:19 +0400, Stanislav Kinsbursky wrote:
>
>> +static int __rpc_pipefs_event(struct rpc_clnt *clnt, unsigned long event,
>> +				struct super_block *sb)
>> +{
>> +	int error;
>> +
>> +	if (!rpc_clnt_skip_event(clnt, event)) {
>> +		error = __rpc_clnt_handle_event(clnt, event, sb);
>> +		if (error)
>> +			return error;
>> +	}
>> +	if (clnt != clnt->cl_parent)
>> +		return __rpc_pipefs_event(clnt->cl_parent, event, sb);
>> +	return 0;
>> +}
> Hi Stanislav,
>
> Recursion in the kernel is generally frowned upon due to the stack size
> limits. Could you please rewrite the above into a simple loop. Something
> along the lines of:
>
> 	for(;;) {
> 		...
>
> 		if (clnt == clnt->cl_parent)
> 			break;
> 		clnt = clnt->cl_parent;
> 	}
>

Hi, Trond.
Yes, sure, I can do this.
