Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:34095 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316Ab0KWQCX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Nov 2010 11:02:23 -0500
Subject: Re: [PATCH] NSM: Replace __attribute_noinline__
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <x6wro4zddv@gzp>
Date: Tue, 23 Nov 2010 11:01:51 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <644981DA-2D65-409F-8E16-F4537FF08D17@oracle.com>
References: <20101122163637.17565.13193.stgit@matisse.1015granger.net> <x6wro4zddv@gzp>
To: "Gabor Z. Papp" <gzp@papp.hu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Nov 23, 2010, at 2:51 AM, Gabor Z. Papp wrote:

> * Chuck Lever <chuck.lever@oracle.com>:
> 
> | Gabor-
> 
> | Can you try this out?  Either it will fix the problem, or it will tell
> | us more about the issue.
> 
> Seems like the problem fixed, but got new one:
> 
> make[3]: Entering directory
> `/home/gzp/src/nfs-utils-1.2.3/utils/statd'
> gcc -DHAVE_CONFIG_H -I. -I../../support/include   -D_GNU_SOURCE -Wall
> -Wextra -Wstrict-prototypes  -pipe -g -O2 -MT sm-notify.o -MD -MP -MF .deps/sm-notify.Tpo -c -o sm-notify.o sm-notify.c sm-notify.c: In function 'smn_bind_address':
> sm-notify.c:247: error: 'AI_NUMERICSERV' undeclared (first use in this function)
> sm-notify.c:247: error: (Each undeclared identifier is reported only once
> sm-notify.c:247: error: for each function it appears in.)
> make[3]: *** [sm-notify.o] Error 1
> 
> AI_NUMERICSERV defined only in glibc 2.3, but not in 2.2.

Apparently so.  I'll look into it.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




