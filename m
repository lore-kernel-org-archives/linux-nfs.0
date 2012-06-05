Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:37677 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754928Ab2FERR2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jun 2012 13:17:28 -0400
Message-ID: <4FCE3F22.4040206@openvz.org>
Date: Tue, 05 Jun 2012 21:17:22 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
To: =?ISO-8859-1?Q?Toralf_F=F6rster?= <toralf.foerster@gmx.de>
CC: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
        Ondrej Zary <linux@rainbow-software.org>,
        Hugh Dickins <hughd@google.com>,
        Kernel development list <linux-kernel@vger.kernel.org>,
        Dave Jones <davej@redhat.com>, Hans de Bruin <jmdebruin@xmsnet.nl>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: Re: [bisected commit 0fc9d10] NFS-server corruption with 3.4
References: <201206051116.17711.linux@rainbow-software.org> <4FCE0A83.4050502@openvz.org> <201206051620.47925.linux@rainbow-software.org> <4FCE1D17.1080904@openvz.org> <87zk8h23wn.fsf@devron.myhome.or.jp> <4FCE2256.7010804@openvz.org> <4FCE2CCE.9000900@openvz.org> <4FCE3BF2.2030608@gmx.de>
In-Reply-To: <4FCE3BF2.2030608@gmx.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Toralf Förster wrote:
> On 06/05/2012 05:59 PM, Konstantin Khlebnikov wrote:
>> Proper fix in attachment.
>>
> That fixes solves the chroot issue I had have - tested at top of
> v3.5-rc1-37-g99becf1
>

Ok, thanks.
