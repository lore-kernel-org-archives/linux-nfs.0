Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.parknet.co.jp ([210.171.160.6]:58258 "EHLO
	mail.parknet.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752812Ab2FEPl2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jun 2012 11:41:28 -0400
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
	<4FCE1D17.1080904@openvz.org>
Date: Wed, 06 Jun 2012 00:07:36 +0900
In-Reply-To: <4FCE1D17.1080904@openvz.org> (Konstantin Khlebnikov's message of
	"Tue, 05 Jun 2012 18:52:07 +0400")
Message-ID: <87zk8h23wn.fsf@devron.myhome.or.jp>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Konstantin Khlebnikov <khlebnikov@openvz.org> writes:

> Hmm, very interesting!
> Please try this patch, it must fix the problem and print some numbers to debug.
>

I think the bug is in radix_tree_for_each_contig().

radix_tree_next_slot() returns NULL if the slot was NULL (i.e. there is
hole). But, slot == NULL is not meaning to stop iterate here. Actually,
if slot is NULL, it gets next chunk.

Bang.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
