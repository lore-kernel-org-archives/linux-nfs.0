Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46740 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751672AbdH1IiN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 28 Aug 2017 04:38:13 -0400
Date: Mon, 28 Aug 2017 04:38:10 -0400
From: Vadim Lomovtsev <vlomovts@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        jlayton@poochiereds.net, davem@davemloft.net,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, pabeni@redhat.com,
        vlomovts@redhat.com
Subject: Re: [PATCH] net: sunrpc: svcsock: fix NULL-pointer exception
Message-ID: <20170828083810.GB7864@dhcp187-32.khw.lab.eng.bos.redhat.com>
References: <1503050447-13362-1-git-send-email-vlomovts@redhat.com>
 <20170825220128.GA6276@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170825220128.GA6276@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 25, 2017 at 06:01:28PM -0400, J. Bruce Fields wrote:
> On Fri, Aug 18, 2017 at 06:00:47AM -0400, Vadim Lomovtsev wrote:
> > While running nfs/connectathon tests kernel NULL-pointer exception
> > has been observed due to races in svcsock.c.
> > 
> > Race is appear when kernel accepts connection by kernel_accept
> > (which creates new socket) and start queuing ingress packets
> > to new socket. This happanes in ksoftirq context which concurrently
> > on a differnt core while new socket setup is not done yet.
> > 
> > The fix is to re-order socket user data init sequence, add NULL-ptr
> > check before callback call along with barriers to prevent kernel crash.
> > 
> > Test results: nfs/connectathon reports '0' failed tests for about 200+ iterations.
> 
> By the way, is there anything special about your setup that allows you
> to reproduce this?  There's nothing special about connectathon tests, so
> I'm just wondering why we haven't had a lot of reports of this.
