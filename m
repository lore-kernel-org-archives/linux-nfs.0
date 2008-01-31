From: "Anirban Sinha" <ASinha-z4qIPS1Syiu/3pe1ocb+swC/G2K4zDHf@public.gmane.org>
Subject: kernel exports table flushes out on running exportfs -a over mips
Date: Wed, 30 Jan 2008 17:34:13 -0800
Message-ID: <DDFD17CC94A9BD49A82147DDF7D545C5743B89@exchange.ZeugmaSystems.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
To: <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.zeugmasystems.com ([192.139.122.66]:10231 "EHLO
	zeugmasystems.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754312AbYAaBeu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jan 2008 20:34:50 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi:

I am seeing an unusual problem on running nfs server on mips. Over Intel
this does not happen. When I run exportfs -a on the server when the
clients have already mounted their nfs filesystem, the kernel exports
table as can be seen from /proc/fs/nfs/exports gets completely flushed
out. We (me and one another colleague) have done some digging (mostly
looking into nfsutils codebase) and it looks like a kernel side issue.
We had also asked folks in the linux-mips mailing list, but apparently
no one has any clue. I am just hoping that those who are more familiar
with the user level and kernel side of nfs might me something more to
chew on. If you can give any suggestions that will be really useful. If
you think the information I provided is not enough, I can give you any
other information you need in this regard.

We are using mips SB1 64 bit processor and running a 2.6.17 kernel from
linux-mips.org.

Thanks in advance,
Ani
