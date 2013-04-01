Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cpsmtpb-ews06.kpnxchange.com ([213.75.39.9]:62075 "EHLO
	cpsmtpb-ews06.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752740Ab3DARzu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Apr 2013 13:55:50 -0400
Message-ID: <1364838943.21627.60.camel@x61.thuisdomein>
Subject: [PATCH 0/8] do not export kernel integer types to userspace
From: Paul Bolle <pebolle@tiscali.nl>
To: Jason Wang <jasowang@redhat.com>, Krishna Kumar <krkumar2@in.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Rusty Russell <rusty@rustcorp.com.au>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Chris Mason <chris.mason@fusionio.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Amit Shah <amit.shah@redhat.com>, Mikael Starvik <starvik@axis.com>,
        Jesper Nilsson <jesper.nilsson@axis.com>
Cc: virtualization@lists.linux-foundation.org, linux-btrfs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cris-kernel@axis.com,
        linux-kernel@vger.kernel.org
Date: Mon, 01 Apr 2013 19:55:43 +0200
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This short series was triggered by a compile error I ran into when trying to
build the lguest tool (see PATCH 1/8). After fixing that error I decided to attempt to
solve all related problems.

Paul Bolle (8):
  virtio_net: do not export "u16" to userspace
  headers_check: add check for kernel integer types
  virtio: do not export "u16" and "u64" to userspace
  headers_check: check kernel types inside #define
  btrfs: do not export "u64" to userspace
  nfsd4: do not export "u64" to userspace
  virtio: do not export "u32" to userspace
  cris: do not export "u8" and friends to userspace

 arch/cris/include/uapi/arch-v10/arch/sv_addr_ag.h | 20 ++++++++++----------
 include/uapi/linux/btrfs.h                        |  2 +-
 include/uapi/linux/nfs4.h                         |  2 +-
 include/uapi/linux/virtio_balloon.h               |  4 ++--
 include/uapi/linux/virtio_console.h               |  2 +-
 include/uapi/linux/virtio_net.h                   |  2 +-
 scripts/headers_check.pl                          | 21 +++++++++++++++++++++
 7 files changed, 37 insertions(+), 16 deletions(-)

-- 
1.7.11.7

