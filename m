From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: [NFS] nfs-utils 1.0.12 cant build
Date: Mon, 15 Dec 2008 10:20:13 -0500
Message-ID: <4d569c330812150720s44fc07c1n8f12a2bc697d7940@mail.gmail.com>
References: <1229295391.2924.5.camel@jonspcb>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs-TtF/mJH4Jtrk1uMJSBkQmQ@public.gmane.org
To: "Jonathan Andrews" <jon-6sjJsz/Jqtu8qtKVGud/9w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:34702 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751329AbYLOPY2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Dec 2008 10:24:28 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1LCFJ4-0004rn-Cp
	for linux-nfs@vger.kernel.org; Tue, 16 Dec 2008 02:24:26 +1100
In-Reply-To: <1229295391.2924.5.camel@jonspcb>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 14, 2008 at 5:56 PM, Jonathan Andrews <jon-6sjJsz/Jqtu8qtKVGud/9w@public.gmane.org> wrote:
>
> configure:22158: gcc -o conftest -g -O2  -D_GNU_SOURCE  conftest.c -lblkid   >&5
> /usr/lib/libblkid.a(probe.o)(.text+0x2b3): In function `set_uuid':
> /root/src/GNU/unmodified_gnu/nfs-utils-1.0.12/e2fsprogs-1.41.3/lib/blkid/probe.c:132: undefined reference to `uuid_is_nu
> ll'
> /usr/lib/libblkid.a(probe.o)(.text+0x2d0):/root/src/GNU/unmodified_gnu/nfs-utils-1.0.12/e2fsprogs-1.41.3/lib/blkid/probe
> .c:133: undefined reference to `uuid_unparse'
> /usr/lib/libblkid.a(probe.o)(.text+0x3af): In function `get_ext2_info':
> /root/src/GNU/unmodified_gnu/nfs-utils-1.0.12/e2fsprogs-1.41.3/lib/blkid/probe.c:162: undefined reference to `uuid_is_nu
> ll'
> collect2: ld returned 1 exit status
> configure:22164: $? = 1
> configure: failed program was:
> | /* confdefs.h.  */
>
>
> Anyone any ideas ?

To answer your question:  Try to use either "--without-uuid" or
"--disable-uuid" during configure.  (I can't remember which is
correct, and the --help documentation was wrong at one point.)

A question for you:  This is a pretty old version.  Why not build 1.1.4 ?

K.C.

------------------------------------------------------------------------------
SF.Net email is Sponsored by MIX09, March 18-20, 2009 in Las Vegas, Nevada.
The future of the web can't happen without you.  Join us at MIX09 to help
pave the way to the Next Web now. Learn more and register at
http://ad.doubleclick.net/clk;208669438;13503038;i?http://2009.visitmix.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

