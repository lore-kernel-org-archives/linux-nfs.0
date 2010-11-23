Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from odpn1.odpn.net ([212.40.96.53]:36765 "EHLO odpn1.odpn.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752594Ab0KWHvZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Nov 2010 02:51:25 -0500
From: "Gabor Z. Papp" <gzp@papp.hu>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NSM: Replace __attribute_noinline__
References: <20101122163637.17565.13193.stgit@matisse.1015granger.net>
Date: Tue, 23 Nov 2010 08:51:24 +0100
Message-ID: <x6wro4zddv@gzp>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

* Chuck Lever <chuck.lever@oracle.com>:

| Gabor-

| Can you try this out?  Either it will fix the problem, or it will tell
| us more about the issue.

Seems like the problem fixed, but got new one:

make[3]: Entering directory
`/home/gzp/src/nfs-utils-1.2.3/utils/statd'
gcc -DHAVE_CONFIG_H -I. -I../../support/include   -D_GNU_SOURCE -Wall
-Wextra -Wstrict-prototypes  -pipe -g -O2 -MT sm-notify.o -MD -MP -MF .deps/sm-notify.Tpo -c -o sm-notify.o sm-notify.c sm-notify.c: In function 'smn_bind_address':
sm-notify.c:247: error: 'AI_NUMERICSERV' undeclared (first use in this function)
sm-notify.c:247: error: (Each undeclared identifier is reported only once
sm-notify.c:247: error: for each function it appears in.)
make[3]: *** [sm-notify.o] Error 1

AI_NUMERICSERV defined only in glibc 2.3, but not in 2.2.
