From: Giulio Troccoli <Giulio.Troccoli-xnMMdYoS6WpEKMMhf/gKZA@public.gmane.org>
Subject: [NFS] Compileing nfs-utils 1.1.5 on RHEL4 fails in tcpwrapper.c
Date: Thu, 26 Mar 2009 16:37:54 +0000
Message-ID: <6680A70380E6BA44A2D94ED7085718EE066A08079D@ln1exc03>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Giulio Troccoli <Giulio.Troccoli-xnMMdYoS6WpEKMMhf/gKZA@public.gmane.org>
To: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:51482 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752650AbZCZQxo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Mar 2009 12:53:44 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Lmspo-00041b-VQ
	for linux-nfs@vger.kernel.org; Fri, 27 Mar 2009 03:53:41 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I want to upgrade nfs-utils from 1.0.6 to 1.1.5, so I have downloaded the source code form sourceforge.net and issue the following ./configure command

./configure --disable-nfsv4 --disable-static --with-statduser=rpcuser --disable-gss

Which finishes without errors. But then when I make I get the following

make[2]: Entering directory `/usr/local/src/nfs-utils-1.1.5/support/misc'
gcc -DHAVE_CONFIG_H -I. -I../../support/include   -I/usr/include -D_GNU_SOURCE -Wall -Wstrict-prototypes  -pipe -g -O2 -MT tcpwrapper.o -MD -MP -MF .deps/tcpwrapper.Tpo -c -o tcpwrapper.o tcpwrapper.c
tcpwrapper.c: In function `haccess_add':
tcpwrapper.c:117: warning: implicit declaration of function `TAILQ_EMPTY'
tcpwrapper.c:119: error: syntax error before "else"
tcpwrapper.c: At top level:
tcpwrapper.c:121: error: syntax error before '}' token
tcpwrapper.c: In function `haccess_lookup':
tcpwrapper.c:131: warning: implicit declaration of function `TAILQ_FOREACH'
tcpwrapper.c:131: error: `list' undeclared (first use in this function)
tcpwrapper.c:131: error: (Each undeclared identifier is reported only once
tcpwrapper.c:131: error: for each function it appears in.)
tcpwrapper.c:131: error: syntax error before '{' token
make[2]: *** [tcpwrapper.o] Error 1
make[2]: Leaving directory `/usr/local/src/nfs-utils-1.1.5/support/misc'
make[1]: *** [all-recursive] Error 1
make[1]: Leaving directory `/usr/local/src/nfs-utils-1.1.5/support'
make: *** [all-recursive] Error 1

I have found the TAILQ_ definitions in utils/idmapd/queue.h but most importantly in /usr/include/sys/queue.h which tcpwrapper.c should have picked up.

Can anubody help? I'm not subscribed to the list so please make sure to CC me.

Thanks
Giulio


Linedata Services (UK) Ltd
Registered Office: Bishopsgate Court, 4-12 Norton Folgate, London, E1 6DB
Registered in England and Wales No 3027851    VAT Reg No 778499447





------------------------------------------------------------------------------
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

