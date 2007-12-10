From: Jeff Layton <jlayton@redhat.com>
Subject: Re: Client performance questions
Date: Mon, 10 Dec 2007 18:26:11 -0500
Message-ID: <20071210182611.56cdc01b@tleilax.poochiereds.net>
References: <0a15723c4b267d4eb8b5ad05800315c0@swip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: "Fredrik Lindgren" <fli-FpffG6+3qsA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37985 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751798AbXLJX0R (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Dec 2007 18:26:17 -0500
In-Reply-To: <0a15723c4b267d4eb8b5ad05800315c0-FpffG6+3qsA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 10 Dec 2007 22:52:51 +0100
"Fredrik Lindgren" <fli-FpffG6+3qsA@public.gmane.org> wrote:

> Hello
> 
> We have a mail-application running on a set of Linux machines using
> NFS for the storage. Recently iowait on the machines has started to
> become a problem, and it seems that they can't quite keep up. Iowait
> figures of 50% or above are not uncommon during peak hours.
> 

High iowait numbers are not a problem in and of themselves. A high
iowait number is just indicative that the machine is spending a lot of
its time waiting for I/O. On a busy NFS client, that may be expected
particularly if the machine isn't doing much else CPU-wise.

The big question is whether you're getting enough throughput for your
applications. iowait percentages can't tell you that. That's not to say
that you don't have a performance issue, but you'll probably need to
get some better metrics than iowait figures to track it down.

-- 
Jeff Layton <jlayton@redhat.com>
