Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:44160 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055Ab3H1Njp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Aug 2013 09:39:45 -0400
Received: by mail-vb0-f46.google.com with SMTP id p13so4109894vbe.33
        for <linux-nfs@vger.kernel.org>; Wed, 28 Aug 2013 06:39:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <785211889.113142.1370042643416.JavaMail.root@erie.cs.uoguelph.ca>
References: <CACQjR_CsRY4O+S1Zx-QabXYBUtRMKHa8o7ymCmLqSHa9UdgNFQ@mail.gmail.com>
 <785211889.113142.1370042643416.JavaMail.root@erie.cs.uoguelph.ca>
From: William Dauchy <wdauchy@gmail.com>
Date: Wed, 28 Aug 2013 15:39:25 +0200
Message-ID: <CAJ75kXYYJ5mY085BjpvwQw+YS5ojV_uA_9WoppkF7R=ammLP8g@mail.gmail.com>
Subject: Re: NFS client hangs after server reboot
To: Rick Macklem <rmacklem@uoguelph.ca>
Cc: Bram Vandoren <brambi@gmail.com>, "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jun 1, 2013 at 1:24 AM, Rick Macklem <rmacklem@uoguelph.ca> wrote:
> I'll take a look. I wrote that code about 10 years ago, so I don't remember
> all the details w.r.t. the records in the stable restart file. If you truncate
> the file, there won't be any recovery on the next reboot, so you need to
> unmount all the NFSv4 mounts on it before rebooting for that case.

Any news on this subject? I'm getting the same issue.

-- 
William
