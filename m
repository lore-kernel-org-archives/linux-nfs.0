From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] zerocopy NFS for 2.5.36
Date: Wed, 18 Sep 2002 16:00:57 -0700 (PDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20020918.160057.17194839.davem@redhat.com>
References: <20020918.171431.24608688.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: taka@valinux.co.jp
In-Reply-To: <20020918.171431.24608688.taka@valinux.co.jp>
List-ID: <nfs.lists.sourceforge.net>

   From: Hirokazu Takahashi <taka@valinux.co.jp>
   Date: Wed, 18 Sep 2002 17:14:31 +0900 (JST)
   
   
   1)
   ftp://ftp.valinux.co.jp/pub/people/taka/2.5.36/va10-hwchecksum-2.5.36.patch
   This patch enables HW-checksum against outgoing packets including UDP frames.
   
Can you explain the TCP parts?  They look very wrong.

It was discussed long ago that csum_and_copy_from_user() performs
better than plain copy_from_user() on x86.  I do not remember all
details, but I do know that using copy_from_user() is not a real
improvement at least on x86 architecture.

The rest of the changes (ie. the getfrag() logic to set
skb->ip_summed) looks fine.

   3)
   ftp://ftp.valinux.co.jp/pub/people/taka/2.5.36/va-csumpartial-fix-2.5.36.patch
   This patch fixes the problem of x86 csum_partilal() routines which
   can't handle odd addressed buffers.
   
I've sent Linus this fix already.
