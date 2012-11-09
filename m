Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:58598 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754622Ab2KISpi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Nov 2012 13:45:38 -0500
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1TWtaC-0001nX-69
	for linux-nfs@vger.kernel.org; Fri, 09 Nov 2012 19:45:36 +0100
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1TWta9-0006Vz-6I
	for linux-nfs@vger.kernel.org; Fri, 09 Nov 2012 19:45:33 +0100
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: Re: Kernel update 3.5.7 -> 3.6.3 breaks NFS4
Date: Fri, 9 Nov 2012 18:45:32 +0000 (UTC)
Message-ID: <k7jj0c$nak$1@ultimate100.geggus.net>
References: <k6ebva$1kf$1@ultimate100.geggus.net> <20121026171549.GA11806@fieldses.org> <20121029094038.GA14836@geggus.net> <20121029150203.GB9502@fieldses.org> <20121105165459.GA2958@geggus.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sven Geggus <lists@fuchsschwanzdomain.de> wrote:

> OK, I now figured out which commit did cause the problem:
> 
> Thus "git diff 08843b79..cc8362b1" on a linux-stable tree from
> git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git should
> give us the relevant changes.

After a private conversation with J. Bruce Fields I figured out that
I have not been quite there yet. So here comes a FTR post what
exactly caused my problem.

It is the following change:

$ git diff d9c2ede63c74048dfddbb129c59ac01176b0ab71 bbf43dc888833ac0539e437dbaeb28bfd4fbab9f
diff --git a/include/linux/sunrpc/cache.h
b/include/linux/sunrpc/cache.h
index 6def1f6..af42596 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -217,8 +217,6 @@ extern int qword_get(char **bpp, char *dest, int
bufsize);
 static inline int get_int(char **bpp, int *anint)
 {
        char buf[50];
-       char *ep;
-       int rv;
        int len = qword_get(bpp, buf, sizeof(buf));
 
        if (len < 0)
@@ -226,11 +224,9 @@ static inline int get_int(char **bpp, int
*anint)
        if (len == 0)
                return -ENOENT;
 
-       rv = simple_strtol(buf, &ep, 0);
-       if (*ep)
+       if (kstrtoint(buf, 0, anint))
                return -EINVAL;
 
-       *anint = rv;
        return 0;
 }

Reverting this change on recent kernels makes them work for me again.

Sven


-- 
Unix is simple and coherent, but it takes a genius – or at any rate a
programmer – to understand and appreciate the simplicity
(Dennis M. Ritchie)
/me is giggls@ircnet, http://sven.gegg.us/ on the Web
