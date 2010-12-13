From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 3/3] sm-notify: Make use of AI_NUMERICSERV conditional
Date: Mon, 13 Dec 2010 15:00:34 -0500
Message-ID: <4D067B62.5020101@RedHat.com>
References: <20101206160206.18361.26178.stgit@matisse.1015granger.net> <20101206161002.18361.24632.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56524 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754038Ab0LMUAh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Dec 2010 15:00:37 -0500
In-Reply-To: <20101206161002.18361.24632.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/06/2010 11:10 AM, Chuck Lever wrote:
> Gabor Papp reports nfs-utils-1.2.3 doesn't build on his system that
> uses glibc-2.2.5:
> 
> make[3]: Entering directory
> `/home/gzp/src/nfs-utils-1.2.3/utils/statd'
> gcc -DHAVE_CONFIG_H -I. -I../../support/include   -D_GNU_SOURCE -Wall
> 	-Wextra -Wstrict-prototypes  -pipe -g -O2 -MT sm-notify.o -MD
> 	-MP -MF .deps/sm-notify.Tpo -c -o sm-notify.o sm-notify.c
> 	sm-notify.c: In function 'smn_bind_address':
> sm-notify.c:247: error: 'AI_NUMERICSERV' undeclared (first use in this function)
> sm-notify.c:247: error: (Each undeclared identifier is reported only once
> sm-notify.c:247: error: for each function it appears in.)
> make[3]: *** [sm-notify.o] Error 1
> 
> According to the getaddrinfo(3) man page, AI_NUMERICSERV is available
> only since glibc 2.3.4.  getaddrinfo(3) seems to convert strings
> containing a number to the right port value without the use of
> AI_NUMERICSERV, so I think we can survive on older glibc's without it.
> It will allow admins to specify service names as well as port numbers
> on those versions.
> 
> There are uses of AI_NUMERICSERV in gssd and in nfs_svc_create().  The
> one in nfs_svc_create() is behind HAVE_LIBTIRPC, and the other is a
> issue only for those who want to deploy Kerberos -- likely in both
> cases, a more modern glibc will be present.  I'm going to leave those
> two.
> 
> Fix for:
> 
>   https://bugzilla.linux-nfs.org/show_bug.cgi?id=195
> 
> Reported-by: "Gabor Z. Papp" <gzp-2g/1Y3AqmNE@public.gmane.org>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Committed... 

steved.
