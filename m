From: "Gabor Z. Papp" <gzp-2g/1Y3AqmNE@public.gmane.org>
Subject: nfs-utils 1.1.3 and glibc 2.2
Date: Mon, 28 Jul 2008 16:30:21 +0200
Message-ID: <x6vdyqkrnm@gzp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from odpn1.odpn.net ([212.40.96.53]:38301 "EHLO odpn1.odpn.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756861AbYG1PAB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jul 2008 11:00:01 -0400
Received: from odpn1.odpn.net [212.40.96.53]
	by odpn1.odpn.net for linux-nfs@vger.kernel.org
	id 1KNTjx-0005lj-Qi; Mon, 28 Jul 2008 16:30:21 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

seems like nfs-utils no more compatible with glibc 2.2?

make[2]: Entering directory
`/home/gzp/src/nfs-utils-1.1.3/utils/mount'
gcc -DHAVE_CONFIG_H -I. -I../../support/include
-I../../support/include -D_GNU_SOURCE -Wall -Wstrict-prototypes  -pipe
-g -O2 -MT network.o -MD -MP -MF .deps/network.Tpo -c -o network.o network.c
network.c: In function 'nfs_name_to_address':
network.c:154: error: 'AI_ADDRCONFIG' undeclared (first use in this function)
network.c:154: error: (Each undeclared identifier is reported only once
network.c:154: error: for each function it appears in.)
network.c:160: error: 'AI_V4MAPPED' undeclared (first use in this function)
network.c:160: error: 'AI_ALL' undeclared (first use in this function)
make[2]: *** [network.o] Error 1
make[2]: Leaving directory `/home/gzp/src/nfs-utils-1.1.3/utils/mount'

1.1.2 compiles fine.
