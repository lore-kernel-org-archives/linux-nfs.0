Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:9533 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752469AbdKHEul (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Nov 2017 23:50:41 -0500
Subject: Re: [PATCH 21/21] sunrpc: exit_net cleanup check added
To: Stephen Hemminger <stephen@networkplumber.org>
Cc: netdev@vger.kernel.org, linux-nfs@vger.kernel.org,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>
References: <c450ca1b-67dd-8cef-5cb5-a2dfeaaa793e@virtuozzo.com>
 <20171108102205.55aa82eb@shemminger-XPS-13-9360>
From: Vasily Averin <vvs@virtuozzo.com>
Message-ID: <639bad93-86a6-a21a-f821-cbaf887da851@virtuozzo.com>
Date: Wed, 8 Nov 2017 07:50:27 +0300
MIME-Version: 1.0
In-Reply-To: <20171108102205.55aa82eb@shemminger-XPS-13-9360>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2017-11-08 04:22, Stephen Hemminger wrote:
> On Sun, 5 Nov 2017 13:02:44 +0300
> Vasily Averin <vvs@virtuozzo.com> wrote:
>> +	WARN(!list_empty(&sn->all_clients),
>> +	     "net %p exit: sunrpc all_clients list is not empty\n", net);
> 
> Don't print a kernel pointer, this is a security leak.

Yes, you're right, I've submitted fixed patch in v3 already,
but seems will prepare v4 with simple  WARN_ON_ONCE(!list_empty())
