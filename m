From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] zerocopy NFS for 2.5.33
Date: Mon, 09 Sep 2002 02:04:00 -0700 (PDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20020909.020400.72665590.davem@redhat.com>
References: <20020909.161123.74745039.taka@valinux.co.jp>
	<20020909.001902.28439948.davem@redhat.com>
	<20020909.175821.108746773.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: scott.feldman@intel.com, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: taka@valinux.co.jp
In-Reply-To: <20020909.175821.108746773.taka@valinux.co.jp>
List-ID: <nfs.lists.sourceforge.net>

   From: Hirokazu Takahashi <taka@valinux.co.jp>
   Date: Mon, 09 Sep 2002 17:58:21 +0900 (JST)

   As far as I know e1000 has a feature that it can split a jumbo UDP frame
   into some IP fragments.
   
I doubt this, because very rarely do vendors of commodity networking
cards implement things outside of Microsoft's NDIS (Network Driver
Interface Specification) and what I have described is what they define
for fragmentation offloading.

Maybe some new revision has the feature you suggest.
