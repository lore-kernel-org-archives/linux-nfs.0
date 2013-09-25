Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:64051 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754795Ab3IYVIQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Sep 2013 17:08:16 -0400
Date: Wed, 25 Sep 2013 14:07:42 -0700
From: Zach Brown <zab@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Anna Schumaker <schumaker.anna@gmail.com>,
        Szeredi Miklos <miklos@szeredi.hu>, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Bryan Schumaker <bjschuma@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        Eric Wong <normalperson@yhbt.net>
Subject: Re: [RFC] extending splice for copy offloading
Message-ID: <20130925210742.GG30372@lenny.home.zabbo.net>
References: <1378919210-10372-1-git-send-email-zab@redhat.com>
 <CAELBmZBGD4rph=gjLCPKCdEj+nzEQ-F=DExoL+h3vRm7qF7dCQ@mail.gmail.com>
 <20130925183828.GA30372@lenny.home.zabbo.net>
 <CAFX2JfnyF8kyMYzCdqdr2JkoyQCom1bFLpFj89wODjoju54-Ow@mail.gmail.com>
 <20130925190620.GB30372@lenny.home.zabbo.net>
 <20130925195526.GA18971@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130925195526.GA18971@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> A client-side copy will be slower, but I guess it does have the
> advantage that the application can track progress to some degree, and
> abort it fairly quickly without leaving the file in a totally undefined
> state--and both might be useful if the copy's not a simple constant-time
> operation.

I suppose, but can't the app achieve a nice middle ground by copying the
file in smaller syscalls?  Avoid bulk data motion back to the client,
but still get notification every, I dunno, few hundred meg?

> So maybe a way to pass your NONBLOCKy flag to the server would be
> useful?

Maybe, but maybe it also just won't be used in practice.  I'm to the
point where I'd rather we get the stupidest possible thing out there so
that we can learm from actual use of the interface.

- z
