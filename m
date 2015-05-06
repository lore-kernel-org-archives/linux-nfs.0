Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54793 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751158AbbEFUYK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 May 2015 16:24:10 -0400
Message-ID: <554A785A.6090909@RedHat.com>
Date: Wed, 06 May 2015 16:23:54 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Calvin Walton <calvin.walton@kepstin.ca>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] nfs-utils: Run rpcgen using the cpp found by configure.
References: <1429637517-28121-1-git-send-email-calvin.walton@kepstin.ca>
In-Reply-To: <1429637517-28121-1-git-send-email-calvin.walton@kepstin.ca>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/21/2015 01:31 PM, Calvin Walton wrote:
> rpcgen normally runs with a hardcoded cpp path of e.g. /lib/cpp,
> but not all Linux distributions install a cpp there.
> 
> Grab a trick from glibc, and run rpcgen with a cpp-path pointing at
> a script; the script then runs the cpp specified in the CPP
> environment variable - which we set to $CC -E with appropriate
> options.
> 
> Signed-off-by: Calvin Walton <calvin.walton@kepstin.ca>
I'm getting the following errors when I apply this patch:

test -f mount.h && rm -rf mount.h || true
CPP='gcc -E -x c-header' /usr/bin/rpcgen -Y ../../tools/rpcgen -l -o mount_clnt.c mount.x
CPP='gcc -E -x c-header' /usr/bin/rpcgen -Y ../../tools/rpcgen -c -o mount_xdr.c mount.x
CPP='gcc -E -x c-header' /usr/bin/rpcgen -Y ../../tools/rpcgen -h -o mount.h mount.x
execvp: Permission denied
/usr/bin/rpcgen: C preprocessor failed with exit code 1
make[2]: *** [mount_clnt.c] Error 1
make[2]: *** Waiting for unfinished jobs....
Makefile:693: recipe for target 'mount_clnt.c' failed
execvp: Permission denied
execvp: Permission denied
/usr/bin/rpcgen: C preprocessor failed with exit code 1
make[2]: *** [mount.h] Error 1
Makefile:701: recipe for target 'mount.h' failed
/usr/bin/rpcgen: C preprocessor failed with exit code 1
make[2]: *** [mount_xdr.c] Error 1
Makefile:697: recipe for target 'mount_xdr.c' failed
make[2]: Leaving directory '/home/src/up/nfs-utils/support/export'
make[1]: *** [all-recursive] Error 1
Makefile:420: recipe for target 'all-recursive' failed
make[1]: Leaving directory '/home/src/up/nfs-utils/support'
make: *** [all-recursive] Error 1
Makefile:463: recipe for target 'all-recursive' failed

steved.
