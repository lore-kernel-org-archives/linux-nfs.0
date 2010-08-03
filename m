Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:59504 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753452Ab0HCBJT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Aug 2010 21:09:19 -0400
Message-Id: <201008030109.o73193bp094241@www262.sakura.ne.jp>
Subject: Re: linux-next NFSD: NULL pointer dereference at nfsd_svc()
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        jlayton@redhat.com
Date: Tue, 03 Aug 2010 10:09:03 +0900
References: <201008020747.o727lqXs064715@www262.sakura.ne.jp> <20100802103214.7eea09eb@corrin.poochiereds.net> <20100802103620.5638dac1@corrin.poochiereds.net> <20100802181634.GD12637@fieldses.org>
In-Reply-To: <20100802181634.GD12637@fieldses.org>
Content-Type: text/plain; charset="ISO-2022-JP"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello.

That patch solved the NULL pointer dereference problem. Thank you.

But I got another problem. After applying that patch on 2.6.35-next-20100802 ,
mount operation fails with timeout error.

# cat /etc/exports
/usr/src/ *(rw,no_root_squash,async)
# time mount 127.0.0.1:/usr/src/ /mnt/
mount: Connection timed out

real    1m21.099s
user    0m0.000s
sys     0m0.028s


2.6.35 works fine. (shown below)

# time mount 127.0.0.1:/usr/src/ /mnt/

real    0m0.105s
user    0m0.000s
sys     0m0.020s

Regards.
