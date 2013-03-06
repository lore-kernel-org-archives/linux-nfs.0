Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:31402 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753567Ab3CFST3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Mar 2013 13:19:29 -0500
Date: Wed, 6 Mar 2013 19:17:35 +0100
From: Oleg Nesterov <oleg@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Tejun Heo <tj@kernel.org>, "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Mandeep Singh Baines <msb@chromium.org>,
        Ming Lei <ming.lei@canonical.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>, Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
Message-ID: <20130306181735.GB18687@redhat.com>
References: <20130304092310.1d21100c@tlielax.poochiereds.net> <CACBanvrc0orXGZ1v+gKHtVPKWYKGEFx46dwoDCjTU78+nPtZyg@mail.gmail.com> <20130304205307.GA13527@redhat.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9286AEEB0@sacexcmbx05-prd.hq.netapp.com> <20130305082308.6607d4db@tlielax.poochiereds.net> <20130305174648.GF12795@htj.dyndns.org> <20130305174954.GG12795@htj.dyndns.org> <20130305140312.243cb094@tlielax.poochiereds.net> <20130305190923.GI12795@htj.dyndns.org> <20130305183941.19ff39ce@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130305183941.19ff39ce@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/05, Jeff Layton wrote:
>
> Anyone up for working out how to handle a freeze event on a process
> that already has a pending signal, while it's being ptraced?

Could you explain the problem?

Oleg.

