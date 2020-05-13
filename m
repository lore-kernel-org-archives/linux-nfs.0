Return-Path: <SRS0=+TNs=63=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B70F0C433E0
	for <linux-nfs@archiver.kernel.org>; Wed, 13 May 2020 17:39:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 4AEFC20659
	for <linux-nfs@archiver.kernel.org>; Wed, 13 May 2020 17:39:08 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732731AbgEMRjH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 13 May 2020 13:39:07 -0400
Received: from smtprelay0150.hostedemail.com ([216.40.44.150]:54324 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1732694AbgEMRjG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 13 May 2020 13:39:06 -0400
Received: from filter.hostedemail.com (clb03-v110.bra.tucows.net [216.40.38.60])
        by smtprelay05.hostedemail.com (Postfix) with ESMTP id 213E41802912F;
        Wed, 13 May 2020 17:39:05 +0000 (UTC)
X-Session-Marker: 6A6F6540706572636865732E636F6D
X-HE-Tag: watch82_4eccc56996d20
X-Filterd-Recvd-Size: 2964
Received: from XPS-9350.home (unknown [47.151.136.130])
        (Authenticated sender: joe@perches.com)
        by omf13.hostedemail.com (Postfix) with ESMTPA;
        Wed, 13 May 2020 17:39:01 +0000 (UTC)
Message-ID: <ecc165c33962d964d518c80de605af632eee0474.camel@perches.com>
Subject: Re: remove kernel_setsockopt and kernel_getsockopt
From:   Joe Perches <joe@perches.com>
To:     Christoph Hellwig <hch@lst.de>,
        "David S. Miller" <davem@davemloft.net>,
        Jakub Kicinski <kuba@kernel.org>
Cc:     Eric Dumazet <edumazet@google.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Jon Maloy <jmaloy@redhat.com>,
        Ying Xue <ying.xue@windriver.com>, drbd-dev@lists.linbit.com,
        linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-nvme@lists.infradead.org,
        target-devel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-cifs@vger.kernel.org, cluster-devel@redhat.com,
        ocfs2-devel@oss.oracle.com, netdev@vger.kernel.org,
        linux-sctp@vger.kernel.org, ceph-devel@vger.kernel.org,
        rds-devel@oss.oracle.com, linux-nfs@vger.kernel.org
Date:   Wed, 13 May 2020 10:38:59 -0700
In-Reply-To: <20200513062649.2100053-1-hch@lst.de>
References: <20200513062649.2100053-1-hch@lst.de>
Content-Type: text/plain; charset="ISO-8859-1"
User-Agent: Evolution 3.36.1-2 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, 2020-05-13 at 08:26 +0200, Christoph Hellwig wrote:
> this series removes the kernel_setsockopt and kernel_getsockopt
> functions, and instead switches their users to small functions that
> implement setting (or in one case getting) a sockopt directly using
> a normal kernel function call with type safety and all the other
> benefits of not having a function call.
> 
> In some cases these functions seem pretty heavy handed as they do
> a lock_sock even for just setting a single variable, but this mirrors
> the real setsockopt implementation - counter to that a few kernel
> drivers just set the fields directly already.
> 
> Nevertheless the diffstat looks quite promising:
> 
>  42 files changed, 721 insertions(+), 799 deletions(-)

trivia:

It might be useful to show overall object size change.

More EXPORT_SYMBOL uses increase object size a little.

And not sure it matters much except it reduces overall object
size, but these patches remove (unnecessary) logging on error
and that could be mentioned in the cover letter too.

e.g.:

-       ret = kernel_setsockopt(queue->sock, SOL_SOCKET, SO_LINGER,
-                       (char *)&sol, sizeof(sol));
-       if (ret) {
-               dev_err(nctrl->device,
-                       "failed to set SO_LINGER sock opt %d\n", ret);
-               goto err_sock;
-       }
+       sock_set_linger(queue->sock->sk, true, 0);



