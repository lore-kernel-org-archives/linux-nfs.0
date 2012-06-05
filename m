Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f174.google.com ([209.85.217.174]:45005 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989Ab2FEPOg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jun 2012 11:14:36 -0400
Message-ID: <4FCE2256.7010804@openvz.org>
Date: Tue, 05 Jun 2012 19:14:30 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
CC: Ondrej Zary <linux@rainbow-software.org>, Hugh Dickins <hughd@google.com>,
        Kernel development list <linux-kernel@vger.kernel.org>,
        Dave Jones <davej@redhat.com>, Hans de Bruin <jmdebruin@xmsnet.nl>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        =?ISO-8859-1?Q?Toralf_F=F6r?= =?ISO-8859-1?Q?ster?=
	<toralf.foerster@gmx.de>,
        richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: Re: [bisected commit 0fc9d10] NFS-server corruption with 3.4
References: <201206051116.17711.linux@rainbow-software.org> <4FCE0A83.4050502@openvz.org> <201206051620.47925.linux@rainbow-software.org>	<4FCE1D17.1080904@openvz.org> <87zk8h23wn.fsf@devron.myhome.or.jp>
In-Reply-To: <87zk8h23wn.fsf@devron.myhome.or.jp>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

OGAWA Hirofumi wrote:
> Konstantin Khlebnikov<khlebnikov@openvz.org>  writes:
>
>> Hmm, very interesting!
>> Please try this patch, it must fix the problem and print some numbers to debug.
>>
>
> I think the bug is in radix_tree_for_each_contig().
>
> radix_tree_next_slot() returns NULL if the slot was NULL (i.e. there is
> hole). But, slot == NULL is not meaning to stop iterate here. Actually,
> if slot is NULL, it gets next chunk.
>
> Bang.

Yeah, you are right, I already found this too.
Currently I think how to fix this more accurately...
