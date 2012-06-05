Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.parknet.co.jp ([210.171.160.6]:58271 "EHLO
	mail.parknet.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754087Ab2FEQSz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jun 2012 12:18:55 -0400
From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Ondrej Zary <linux@rainbow-software.org>, Hugh Dickins <hughd@google.com>,
        Kernel development list <linux-kernel@vger.kernel.org>,
        Dave Jones <davej@redhat.com>, Hans de Bruin <jmdebruin@xmsnet.nl>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Toralf =?iso-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>,
        richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: Re: [bisected commit 0fc9d10] NFS-server corruption with 3.4
References: <201206051116.17711.linux@rainbow-software.org>
	<4FCE0A83.4050502@openvz.org>
	<201206051620.47925.linux@rainbow-software.org>
	<4FCE1D17.1080904@openvz.org> <87zk8h23wn.fsf@devron.myhome.or.jp>
	<4FCE2256.7010804@openvz.org> <4FCE2CCE.9000900@openvz.org>
Date: Wed, 06 Jun 2012 01:18:50 +0900
In-Reply-To: <4FCE2CCE.9000900@openvz.org> (Konstantin Khlebnikov's message of
	"Tue, 05 Jun 2012 19:59:10 +0400")
Message-ID: <87pq9d20lx.fsf@devron.myhome.or.jp>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Konstantin Khlebnikov <khlebnikov@openvz.org> writes:

> Proper fix in attachment.

Maybe, you are going to add the stable tag for next stable?

Thanks.

> radix-tree: fix contiguous iterator
>
> From: Konstantin Khlebnikov <khlebnikov@openvz.org>
>
> This patch fixes bug in macro radix_tree_for_each_contig().
> If radix_tree_next_slot() sees NULL in next slot it returns NULL, but following
> radix_tree_next_chunk() switches iterating into next chunk. As result iterating
> becomes non-contiguous and breaks vfs "splice" and all its users.

-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
