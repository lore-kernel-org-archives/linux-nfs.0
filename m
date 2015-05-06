Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:36367 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751719AbbEFUe1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 May 2015 16:34:27 -0400
Received: by qgeb100 with SMTP id b100so11003069qge.3
        for <linux-nfs@vger.kernel.org>; Wed, 06 May 2015 13:34:26 -0700 (PDT)
Message-ID: <1430944463.32663.2.camel@kepstin.ca>
Subject: Re: [PATCH v2] nfs-utils: Run rpcgen using the cpp found by
 configure.
From: Calvin Walton <calvin.walton@kepstin.ca>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 06 May 2015 16:34:23 -0400
In-Reply-To: <554A785A.6090909@RedHat.com>
References: <1429637517-28121-1-git-send-email-calvin.walton@kepstin.ca>
	 <554A785A.6090909@RedHat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2015-05-06 at 16:23 -0400, Steve Dickson wrote:
> On 04/21/2015 01:31 PM, Calvin Walton wrote:
> > rpcgen normally runs with a hardcoded cpp path of e.g. /lib/cpp,
> > but not all Linux distributions install a cpp there.
> > 
> > Grab a trick from glibc, and run rpcgen with a cpp-path pointing at
> > a script; the script then runs the cpp specified in the CPP
> > environment variable - which we set to $CC -E with appropriate
> > options.
> > 
> > Signed-off-by: Calvin Walton <calvin.walton@kepstin.ca>
> I'm getting the following errors when I apply this patch:
> 
> test -f mount.h && rm -rf mount.h || true
> CPP='gcc -E -x c-header' /usr/bin/rpcgen -Y ../../tools/rpcgen -l -o 
> mount_clnt.c mount.x
> execvp: Permission denied
> /usr/bin/rpcgen: C preprocessor failed with exit code 1

This probably means that the script at tools/rpcgen/cpp failed to get 
the executable permission added during patch application. I'm not sure 
why this happens; the patch header includes "new file mode 100755" as 
git should be expecting.

Doing a chmod +x tools/rpcgen/cpp after applying the patch should fix 
the issue.

-- 
Calvin Walton <calvin.walton@kepstin.ca>
