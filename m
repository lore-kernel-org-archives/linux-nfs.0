Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60078 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756607Ab0HCPuN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Aug 2010 11:50:13 -0400
Date: Tue, 3 Aug 2010 11:48:51 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        jlayton@redhat.com
Subject: Re: linux-next NFSD: NULL pointer dereference at nfsd_svc()
Message-ID: <20100803154851.GA23467@fieldses.org>
References: <201008020747.o727lqXs064715@www262.sakura.ne.jp>
 <20100802103214.7eea09eb@corrin.poochiereds.net>
 <20100802103620.5638dac1@corrin.poochiereds.net>
 <20100802181634.GD12637@fieldses.org>
 <201008030109.o73193bp094241@www262.sakura.ne.jp>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201008030109.o73193bp094241@www262.sakura.ne.jp>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 03, 2010 at 10:09:03AM +0900, Tetsuo Handa wrote:
> Hello.
> 
> That patch solved the NULL pointer dereference problem. Thank you.
> 
> But I got another problem. After applying that patch on 2.6.35-next-20100802 ,
> mount operation fails with timeout error.

Argh, yes, problem found, I think--I'll do some more testing and send
you another attempt....

--b.

> 
> # cat /etc/exports
> /usr/src/ *(rw,no_root_squash,async)
> # time mount 127.0.0.1:/usr/src/ /mnt/
> mount: Connection timed out
> 
> real    1m21.099s
> user    0m0.000s
> sys     0m0.028s
> 
> 
> 2.6.35 works fine. (shown below)
> 
> # time mount 127.0.0.1:/usr/src/ /mnt/
> 
> real    0m0.105s
> user    0m0.000s
> sys     0m0.020s
> 
> Regards.
