Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:43949 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756013Ab2FFKyf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jun 2012 06:54:35 -0400
Message-ID: <4FCF36E6.9060701@openvz.org>
Date: Wed, 06 Jun 2012 14:54:30 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
To: Hans de Bruin <jmdebruin@xmsnet.nl>
CC: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
        Ondrej Zary <linux@rainbow-software.org>,
        Hugh Dickins <hughd@google.com>,
        Kernel development list <linux-kernel@vger.kernel.org>,
        Dave Jones <davej@redhat.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        =?ISO-8859-1?Q?Toralf_F=F6r?= =?ISO-8859-1?Q?ster?=
	<toralf.foerster@gmx.de>,
        richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: Re: [bisected commit 0fc9d10] NFS-server corruption with 3.4
References: <201206051116.17711.linux@rainbow-software.org> <4FCE0A83.4050502@openvz.org> <201206051620.47925.linux@rainbow-software.org> <4FCE1D17.1080904@openvz.org> <87zk8h23wn.fsf@devron.myhome.or.jp> <4FCE2256.7010804@openvz.org> <4FCE2CCE.9000900@openvz.org> <87pq9d20lx.fsf@devron.myhome.or.jp> <4FCE3631.9020407@openvz.org> <4FCE888F.8050605@xmsnet.nl>
In-Reply-To: <4FCE888F.8050605@xmsnet.nl>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hans de Bruin wrote:
> On 06/05/2012 06:39 PM, Konstantin Khlebnikov wrote:
>> OGAWA Hirofumi wrote:
>>> Konstantin Khlebnikov<khlebnikov@openvz.org>  writes:
>>>
>>>> Proper fix in attachment.
>>>
>>> Maybe, you are going to add the stable tag for next stable?
>>>
>>> Thanks.
>>
>> Yes, this definitely must be in next stable 3.4.x , but first I'll wait
>> for confirmation.
>>
>> Guys, who can reproduce this, please check patch "radix-tree: fix
>> contiguous iterator"
>> from my previous mail in this thread.
>>
>>>
>>>> radix-tree: fix contiguous iterator
>>>>
>>>> From: Konstantin Khlebnikov<khlebnikov@openvz.org>
>>>>
>>>> This patch fixes bug in macro radix_tree_for_each_contig().
>>>> If radix_tree_next_slot() sees NULL in next slot it returns NULL, but
>>>> following
>>>> radix_tree_next_chunk() switches iterating into next chunk. As result
>>>> iterating
>>>> becomes non-contiguous and breaks vfs "splice" and all its users.
>>>
>>
>
> I patched on to off v3.4 and Firefox an Thunderbird do not segfault
> anymore. The do not start either. This was de feature on my 'production'
> server I could not reproduce on my test server. Maybe it has something
> to with the different type of nic's.
>
> For the second attempt I branched of at 0fc9d1040313047edf6a39fd and
> applied your patch on top of it. Firefox an Thunderbird where back
> again. So your patch works.
>
> Now I need some git-instructions. Apparently something else is broken. I
> branched of with:
>
> git branch debug 0fc9d1040313047edf6a3
> git checkout debug
> applied the patch.
> git commit -a (got commit 5c09c685ba2d36c3b905220d43ad1b47354e456eed back)
>
> Now I want all commits in my master branch up until ref v3.4 added to my
> debug branch so I can bisect between 5c09 and v3.4
>

No, it does not work in this way. you should apply patch before each test.
You can fix radix-tree bug in find_get_pages_contig() to avoid changing
radix-tree.h and rebuild kernel faster.

--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -927,7 +927,7 @@ repeat:
                  * otherwise we can get both false positives and false
                  * negatives, which is just confusing to the caller.
                  */
-               if (page->mapping == NULL || page->index != iter.index) {
+               if (page->mapping == NULL || page->index != index + ret) {
                         page_cache_release(page);
                         break;
                 }

