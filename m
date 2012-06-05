Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout-de.gmx.net ([213.165.64.22]:54329 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754758Ab2FERDw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jun 2012 13:03:52 -0400
Message-ID: <4FCE3BF2.2030608@gmx.de>
Date: Tue, 05 Jun 2012 19:03:46 +0200
From: =?ISO-8859-1?Q?Toralf_F=F6rster?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
CC: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
        Ondrej Zary <linux@rainbow-software.org>,
        Hugh Dickins <hughd@google.com>,
        Kernel development list <linux-kernel@vger.kernel.org>,
        Dave Jones <davej@redhat.com>, Hans de Bruin <jmdebruin@xmsnet.nl>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: Re: [bisected commit 0fc9d10] NFS-server corruption with 3.4
References: <201206051116.17711.linux@rainbow-software.org> <4FCE0A83.4050502@openvz.org> <201206051620.47925.linux@rainbow-software.org> <4FCE1D17.1080904@openvz.org> <87zk8h23wn.fsf@devron.myhome.or.jp> <4FCE2256.7010804@openvz.org> <4FCE2CCE.9000900@openvz.org>
In-Reply-To: <4FCE2CCE.9000900@openvz.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/05/2012 05:59 PM, Konstantin Khlebnikov wrote:
> Proper fix in attachment.
> 
That fixes solves the chroot issue I had have - tested at top of
v3.5-rc1-37-g99becf1

-- 
MfG/Sincerely
Toralf Förster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
