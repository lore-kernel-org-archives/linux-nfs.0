From: hooanon05@yahoo.co.jp
Subject: Re: Problems with default ACLs over NFS
Date: Mon, 20 Apr 2009 14:17:36 +0900
Message-ID: <7064.1240204656@jrobl>
References: <20090323222427.00bb24e7@werewolf.home> <20090326170513.4e7d377a.akpm@linux-foundation.org> <18513.1238194255@jrobl> <49EBFD18.4070607@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	" " <jamagallon@ono.com>, LKML <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
	lists@fuchsschwanzdomain.de
To: Suresh Jayaraman <sjayaraman@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754176AbZDTFTi@vger.kernel.org>
In-Reply-To: <49EBFD18.4070607@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Suresh Jayaraman:
> The following patch from Trond should fix this issue, I think.
> 
> 
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Wed, 15 Apr 2009 13:58:45 -0400
> Subject: [PATCH] NFS: Fix the XDR iovec calculation in nfs3_xdr_setaclargs
> 
> Commit ae46141ff08f1965b17c531b571953c39ce8b9e2 (NFSv3: Fix posix ACL code)
> introduces a bug in the calculation of the XDR header iovec. In the case
> where we are inlining the acls, we need to adjust the length of the iovec
> req->rq_svec, in addition to adjusting the total buffer length.

Thanx.
But which tree is this patch applied?


J. R. Okajima
