Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:43446 "HELO
        discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S1752360AbeEGQKQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 7 May 2018 12:10:16 -0400
From: Andrew W Elble <aweits@rit.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>, <bfields@redhat.com>,
        <jlayton@kernel.org>
Subject: Re: [PATCH] nfsd: fix error handling in nfs4_set_delegation()
References: <20180418210437.97702-1-aweits@rit.edu>
        <20180503214119.GC27964@fieldses.org>
Date: Mon, 07 May 2018 12:03:35 -0400
In-Reply-To: <20180503214119.GC27964@fieldses.org> (J. Bruce Fields's message
        of "Thu, 3 May 2018 17:41:19 -0400")
Message-ID: <m2bmdr8nc8.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


"J. Bruce Fields" <bfields@fieldses.org> writes:

> Apologies for the slow response, this looks right, I'm just still trying
> to figure out whether this is the only problem here--e.g. does it cause
> problems to have this lease temporarily applied before the delegation is
> hashed?

So the only thing I can currently theorize is that we might eject some
recalls for delegations that will never hit the wire. I think the worst
possibility is that nfsd4_cb_recall_done() might wind up declaring the
callback path to be down? Still looking...

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
