Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36576 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753411AbdHXWNC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 24 Aug 2017 18:13:02 -0400
Date: Thu, 24 Aug 2017 18:13:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Vadim Lomovtsev <vlomovts@redhat.com>,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        davem@davemloft.net, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        pabeni@redhat.com
Subject: Re: [PATCH v4] net: sunrpc: svcsock: fix NULL-pointer exception
Message-ID: <20170824221301.GA26099@fieldses.org>
References: <1503305779-6064-1-git-send-email-vlomovts@redhat.com>
 <1503314587-15420-1-git-send-email-vlomovts@redhat.com>
 <20170823102403.GF1443@dhcp187-32.khw.lab.eng.bos.redhat.com>
 <1503484422.5294.0.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1503484422.5294.0.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 23, 2017 at 06:33:42AM -0400, Jeff Layton wrote:
> I think this one looks fine. Bruce, do you mind picking this one up? It
> might also be reasonable for stable...

Yep, thanks to you both, I'll plan to send a pull request tonight or
tomorrow.

--b.
