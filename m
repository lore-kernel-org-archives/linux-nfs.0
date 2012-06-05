Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:41516 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752352Ab2FEQjS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jun 2012 12:39:18 -0400
Message-ID: <4FCE3631.9020407@openvz.org>
Date: Tue, 05 Jun 2012 20:39:13 +0400
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
References: <201206051116.17711.linux@rainbow-software.org> <4FCE0A83.4050502@openvz.org> <201206051620.47925.linux@rainbow-software.org> <4FCE1D17.1080904@openvz.org> <87zk8h23wn.fsf@devron.myhome.or.jp> <4FCE2256.7010804@openvz.org> <4FCE2CCE.9000900@openvz.org> <87pq9d20lx.fsf@devron.myhome.or.jp>
In-Reply-To: <87pq9d20lx.fsf@devron.myhome.or.jp>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

OGAWA Hirofumi wrote:
> Konstantin Khlebnikov<khlebnikov@openvz.org>  writes:
>
>> Proper fix in attachment.
>
> Maybe, you are going to add the stable tag for next stable?
>
> Thanks.

Yes, this definitely must be in next stable 3.4.x , but first I'll wait for confirmation.

Guys, who can reproduce this, please check patch "radix-tree: fix contiguous iterator"
from my previous mail in this thread.

>
>> radix-tree: fix contiguous iterator
>>
>> From: Konstantin Khlebnikov<khlebnikov@openvz.org>
>>
>> This patch fixes bug in macro radix_tree_for_each_contig().
>> If radix_tree_next_slot() sees NULL in next slot it returns NULL, but following
>> radix_tree_next_chunk() switches iterating into next chunk. As result iterating
>> becomes non-contiguous and breaks vfs "splice" and all its users.
>

