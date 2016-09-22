Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:26567 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752307AbcIVIhQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 22 Sep 2016 04:37:16 -0400
Subject: Re: [PATCH 1/2] NFSD: notifiers registration cleanup
To: Jeff Layton <jlayton@redhat.com>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <6bce434f-4798-42bf-8d4f-e1f33ceb8ad6@virtuozzo.com>
 <1474464010.32518.3.camel@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Scott Mayhew <smayhew@redhat.com>
From: Vasily Averin <vvs@virtuozzo.com>
Message-ID: <84473086-ba97-64c9-ae4d-40bbe82eeef6@virtuozzo.com>
Date: Thu, 22 Sep 2016 11:35:31 +0300
MIME-Version: 1.0
In-Reply-To: <1474464010.32518.3.camel@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 21.09.2016 16:20, Jeff Layton wrote:
> Good catch. I'm not very fond of the refcounting this here but it
> should
> serve the purpose and I don't have anything better to suggest. FWIW, I
> think the nfsd_mutex is held during all of these operations so we
> probably don't need atomics for the refcount.

I've copied idea from netfilters,
look at using of masquerade_notifier_refcount

Perhaps someday in future we'll replace all such cases by some common primitive.
