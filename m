Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:49257 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933687AbdLRQsO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 18 Dec 2017 11:48:14 -0500
Message-ID: <1513615686.7113.10.camel@gmx.de>
Subject: Re: NFS: 82ms wakeup latency 4.14-rc4
From: Mike Galbraith <efault@gmx.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: lkml <linux-kernel@vger.kernel.org>,
        Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Date: Mon, 18 Dec 2017 17:48:06 +0100
In-Reply-To: <20171218163559.GA11829@fieldses.org>
References: <1513610231.7998.13.camel@gmx.de>
         <1513611112.7113.1.camel@gmx.de> <20171218163559.GA11829@fieldses.org>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2017-12-18 at 11:35 -0500, J. Bruce Fields wrote:
> 
> This probably just shows I don't understand the issues, but: isn't this
> the job of preemption?

If this were a PREEMPT kernel, yes, we'd check need_resched() on lock
release etc, but it's a PREEMPT_VOLUNTARY kernel.

	-Mike
