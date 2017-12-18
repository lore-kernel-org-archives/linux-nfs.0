Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:55342 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935504AbdLRRAO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 18 Dec 2017 12:00:14 -0500
Message-ID: <1513616405.7113.18.camel@gmx.de>
Subject: Re: NFS: 82ms wakeup latency 4.14-rc4
From: Mike Galbraith <efault@gmx.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: lkml <linux-kernel@vger.kernel.org>,
        Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Date: Mon, 18 Dec 2017 18:00:05 +0100
In-Reply-To: <20171218163559.GA11829@fieldses.org>
References: <1513610231.7998.13.camel@gmx.de>
         <1513611112.7113.1.camel@gmx.de> <20171218163559.GA11829@fieldses.org>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2017-12-18 at 11:35 -0500, J. Bruce Fields wrote:
> 
> Like I say, I don't really understand the issues here, so it's more a
> question than an objection....  (I don't know any reason a
> cond_resched() would be bad there.)

Think of it this way: what all can be queued up behind that kworker
that is hogging CPU for huge swaths of time?  It's not only userspace
that suffers.

	-Mike
