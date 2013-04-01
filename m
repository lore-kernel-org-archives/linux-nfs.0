Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.17.21]:54604 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756632Ab3DAU0e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Apr 2013 16:26:34 -0400
Received: from mailout-de.gmx.net ([10.1.76.1]) by mrigmx.server.lan
 (mrigmx002) with ESMTP (Nemesis) id 0MEHXK-1UOw5Y2hAm-00FU8u for
 <linux-nfs@vger.kernel.org>; Mon, 01 Apr 2013 22:26:32 +0200
Message-ID: <5159ED75.4020709@gmx.de>
Date: Mon, 01 Apr 2013 22:26:29 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        Dave Jones <davej@redhat.com>
Subject: Re: kernel 3.8.4 : kernel BUG at fs/locks.c:2093!   part #2
References: <514F31AF.3080709@gmx.de> <20130325220143.GD10887@fieldses.org> <20130326144640.GB3353@fieldses.org> <51536610.7010809@gmx.de> <20130327215727.GB27426@fieldses.org> <20130329184331.GH22307@fieldses.org>
In-Reply-To: <20130329184331.GH22307@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/29/2013 07:43 PM, J. Bruce Fields wrote:
> For now, though, this should fix the bug.
> 
> Thanks again for this testing.
With this patch applied on top of 3.8.5 the bug could not be reproduced
any longer (till now).

@Dave
Just Cc:'ed you for your trinity score card
:-)

-- 
MfG/Sincerely
Toralf Förster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
