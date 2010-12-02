Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37310 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751475Ab0LBBnH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 20:43:07 -0500
In-Reply-To: <20101201172224.b8a25bdf.akpm@linux-foundation.org>
References: <1291217804-11257-1-git-send-email-Trond.Myklebust@netapp.com>
 <AANLkTi=C8UtWwctEgBY2584d8fDV3OHpf+mGNnQO8ZJt@mail.gmail.com>
 <1291229669.6609.24.camel@heimdal.trondhjem.org> <AANLkTinsEeKK9LykVAVq60Lsb3caLDJasnKH8kcgSFVp@mail.gmail.com>
 <1291234251.6609.39.camel@heimdal.trondhjem.org> <20101201123341.d12ef362.akpm@linux-foundation.org>
 <alpine.LSU.2.00.1012011258220.18662@tigran.mtv.corp.google.com>
 <alpine.LSU.2.00.1012011311590.18920@tigran.mtv.corp.google.com>
 <20101201133831.ea6ba10a.akpm@linux-foundation.org> <1291240272.6609.50.camel@heimdal.trondhjem.org>
 <20101201141351.8609140b.akpm@linux-foundation.org> <AANLkTimgZPET+T16Qpj_KnpCu==97g-8+_y5dtjNOrxG@mail.gmail.com>
 <20101201143856.51f4f9d9.akpm@linux-foundation.org> <AANLkTi=x1bz5sJXOGERXh8iRHNZa+_gaYOyDecg3G92+@mail.gmail.com>
 <20101201153608.78b331f9.akpm@linux-foundation.org> <AANLkTinbuRRpg7Y8Zu=PD36BO11+qdjZ9uT=u9gCTpDw@mail.gmail.com>
 <20101201172224.b8a25bdf.akpm@linux-foundation.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 1 Dec 2010 17:42:08 -0800
Message-ID: <AANLkTinpvMJsC2XMUyDTaAdozFBLkcdde5_V57Jx-Z4w@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] NFS: Fix a memory leak in nfs_readdir
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@kernel.dk>,
        Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Rik van Riel <riel@redhat.com>,
        Christoph Hellwig <hch@lst.de>, Al Viro <viro@zeniv.linux.org.uk>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Dec 1, 2010 at 5:22 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
>
> What we're talking about is races against memory reclaim, unmount, etc.

Ahh. Those I can believe in. Although I think they'd almost
incidentally be fixed by making inode freeing (which is where the
'struct address_space' is embedded) RCU-safe, which we're going to do
anyway in 38. Then we could make the vmscan code just be a rcu-read
section.

Of course,  I do think the race is basically impossible to hit in
practice regardless.

                            Linus
