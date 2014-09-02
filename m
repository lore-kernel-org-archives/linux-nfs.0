Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49591 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750954AbaIBORo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Sep 2014 10:17:44 -0400
Date: Tue, 2 Sep 2014 10:17:39 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Boaz Harrosh <openosd@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Shakil A Khan <shakilk1729@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Paul McKenney <paulmck@linux.vnet.ibm.com>,
        William Andros Adamson <andros@netapp.com>,
        Jeffrey Layton <jlayton@primarydata.com>,
        "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Next branch: authgss: authgss.c: Fix warnings for
 uninitizlized variable expire
Message-ID: <20140902141739.GB31793@fieldses.org>
References: <1409571154-50408-1-git-send-email-shakilk1729@gmail.com>
 <CAHQdGtQAwp_QuQE-xmjJNkcxbu7g4QtYQv8qrPT_qWpkym1GZg@mail.gmail.com>
 <5405A15F.2060002@gmail.com>
 <20140902132140.GA31793@fieldses.org>
 <5405CD51.9020601@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5405CD51.9020601@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 02, 2014 at 04:59:45PM +0300, Boaz Harrosh wrote:
> uninitialized_var was made to be a friend not an enemy, in the face of real
> ugliness it is the best we can do. And that is what it should communicate to
> everyone. Why has it become everyone's favorite blasphemy I do not know.

Not personally claiming it should never be used, just that this
particular case is kind of extreme, since unless I'm missing a real
compilication it's basically just:

	if (ctx)
		assign to expire
	...
	if (ctx)
		use expire

A compiler wouldn't have to be that smart to actually prove to itself
that expire is initialized at the last step, and that it's not only
failing to do that but actually flagging it as possibly unitialized is
weird.

--b.
