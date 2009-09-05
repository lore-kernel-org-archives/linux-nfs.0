From: Pacho Ramos <pacho-wnk7FUYfzmtu2DZcH3qp6zJQgOOX0AMFMQBsIrBqeMw@public.gmane.org>
Subject: umount -a -f -t nfs doesn't work when a file has been written and
 "-l" option is needed
Date: Sat, 05 Sep 2009 11:16:14 +0200
Message-ID: <1252142174.14467.24.camel@localhost>
Reply-To: pacho-wnk7FUYfzmtu2DZcH3qp6zJQgOOX0AMFMQBsIrBqeMw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp02.jazztel.es ([62.14.3.171]:49813 "EHLO smtp02.jazztel.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751072AbZIEJQN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Sep 2009 05:16:13 -0400
Received: from [87.222.151.142] (helo=[192.168.1.201])
	by smtp02.jazztel.es with esmtpa (Exim 4.69)
	(envelope-from <pacho-wnk7FUYfzmtu2DZcH3qp6zJQgOOX0AMFMQBsIrBqeMw@public.gmane.org>)
	id 1MjrJJ-0006VL-GW
	for linux-nfs@vger.kernel.org; Sat, 05 Sep 2009 11:11:53 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I suffer the following problem with nfs since a lot of time, now, I am
using nfs-utils-1.2.0, but older versions were affected too.

When I write a file on a mounted nfs filesystem and server goes down, I
am unable to umount it even with "-f" option, it simply hangs. On the
other hand, if no file was written (for example, it was simply read)
there is no problem and "umount -f" works as expected.

Seems that I need to run "umount -l" for being able to unmount it, even
when I expected that "-f" should be enough.

Is this the proper behavior or something is going wrong?

Thanks a lot :-)



