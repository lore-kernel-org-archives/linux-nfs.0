From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] zerocopy NFS for 2.5.33
Date: Mon, 09 Sep 2002 00:19:02 -0700 (PDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20020909.001902.28439948.davem@redhat.com>
References: <20020909.161123.74745039.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: taka@valinux.co.jp
In-Reply-To: <20020909.161123.74745039.taka@valinux.co.jp>
List-ID: <nfs.lists.sourceforge.net>

   From: Hirokazu Takahashi <taka@valinux.co.jp>
   Date: Mon, 09 Sep 2002 16:11:23 +0900 (JST)

   Using TSO code is commented out at this moment as TSO for UDP isn't
   implemented yet. I'm waiting for it so that we would remove "#ifdef NotYet"
   to send jumbo UDP frames without any fragmentation and any checksumming.
   Then I hope we will get great performance.
   
Actually, device interface for what could be used is there, see
NETIF_F_FRAGLIST.  No devices set this and IP never makes use of it
yet though :-)

Acenic and Tigon3 will be able to do this, probably e1000 has this
feature as well.

But it does not work how you imagine.  One passes already fragmented
list of packets to card, and it can checksum the packet if you tell it
which descriptor is first of fragmented frame and which is last.

It does not do the fragmentation of UDP frames for you, only
checksumming of UDP portion.  No card does what you mention.

Franks a lot,
David S. Miller
davem@redhat.com
