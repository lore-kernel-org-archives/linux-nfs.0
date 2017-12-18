Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:60488 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758910AbdLRSfP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 18 Dec 2017 13:35:15 -0500
Message-ID: <1513622090.7113.66.camel@gmx.de>
Subject: Re: NFS: 82ms wakeup latency 4.14-rc4
From: Mike Galbraith <efault@gmx.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: lkml <linux-kernel@vger.kernel.org>,
        Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Date: Mon, 18 Dec 2017 19:34:50 +0100
In-Reply-To: <20171218172711.GA12454@fieldses.org>
References: <1513610231.7998.13.camel@gmx.de>
         <1513611112.7113.1.camel@gmx.de> <20171218163559.GA11829@fieldses.org>
         <1513616405.7113.18.camel@gmx.de> <1513617456.7113.25.camel@gmx.de>
         <20171218172711.GA12454@fieldses.org>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2017-12-18 at 12:27 -0500, J. Bruce Fields wrote:
> I'd forgotten about throughput/latency tradeoffs--but
> couldn't those in theory be managed by runtime configuration of the
> sceduler, or at least some smaller hammer than turning off preemption
> entirely?

A kernel that has all of the goop required to support preemption can't
possibly perform as well as a kernel that can simply assume everything
is safe.  All that infrastructure costs cycles.

	-Mike
