Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:45467 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753022Ab2H1QLd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Aug 2012 12:11:33 -0400
Received: by lagy9 with SMTP id y9so3402145lag.19
        for <linux-nfs@vger.kernel.org>; Tue, 28 Aug 2012 09:11:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHVgHyX9aDLjYH0QwUCjx8tXwjsdm=MqH2GPY_68P6XHkYGhVQ@mail.gmail.com>
References: <CAFtxgO5if9qDf9Lex+=hPjrQBgy9ZOnQDr+CWvGY2U7dpC3dOQ@mail.gmail.com>
	<CAHVgHyX9aDLjYH0QwUCjx8tXwjsdm=MqH2GPY_68P6XHkYGhVQ@mail.gmail.com>
Date: Tue, 28 Aug 2012 12:11:31 -0400
Message-ID: <CAFtxgO6FNuqOcvXvu_Y_-NmojpyC2GHiX5rpMQuY4u4zYYbwWg@mail.gmail.com>
Subject: Re: [NFS v4.1] State manager error 22?
From: Jeff Garzik <jeff@garzik.org>
To: Andy Adamson <androsadamson@gmail.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 28, 2012 at 12:06 PM, Andy Adamson <androsadamson@gmail.com> wrote:
> Which kernel?

Sorry!  I had highlighted the kernel version for pasting, then forgot
to paste it:

     3.5.2-3.fc17.i686

> Note that there are multiple checks on the successful CREATE_SESSION
> response that will trigger the client to reject the CREATE_SESSION
> response with -EINVAL.
>
> For example, if the recv maximum response size is greater than the
> sent maximum response size, or if the recv maximum number of
> operations is less than the sent maximum number of operations.....

Would this be nfs4_reclaim_lease(), nfs4_check_lease(),
nfs4_reset_session() or nfs4_bind_conn_to_session()?

Trying to narrow down where the check fails, and there's a lot of code
that seemingly might cause a failure there.

Thanks,

     Jeff
