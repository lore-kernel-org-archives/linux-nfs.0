From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: rpc.mountd --manage-gids breaks on UID differences
Date: Fri, 27 Nov 2009 14:05:35 -0500
Message-ID: <20091127190535.GA7985@fieldses.org>
References: <20091117153928.GA12493@dot.freshdot.net> <20091117200831.GA3969@fieldses.org> <20091126091657.GL15295@dot.freshdot.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41591 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751007AbZK0TEm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Nov 2009 14:04:42 -0500
Received: from bfields by fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1NE68N-0002C0-Pi
	for linux-nfs@vger.kernel.org; Fri, 27 Nov 2009 14:05:35 -0500
In-Reply-To: <20091126091657.GL15295-N0d2glMUd7m2/GFIlvLUCQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 26, 2009 at 10:16:58AM +0100, Sander Smeenk wrote:
> ** Sorry for messing up the thread - My mailconfig started rejecting
> mail from vger.kernel.org for which i am eternally sorry. This message
> i'm replying to was copied from marc.info **
> 
> Quoting J. Bruce Fields (bfields@fieldses.org):
> 
> > > The timeframe described above matches the lines from the beginning
> > > up to 3732517.859721 in the server debug log[2]. I'd have to dig in
> > > the kernel code to find out what lines 3732513.221898 through
> > > 3732513.221913 exactly tell me.
> > > Is anyone on this list an RPC-code ninja?
> >
> > I don't think there's anything interesting in there.
> > If you do:
> > 
> > 	date +%s >/proc/net/rpc/auth.unix.gid/flush
> > 	strace -e trace=read,write -s4096 -p`pidof rpc.mountd` 
> > 
> > then do whatever you do the client to reproduce the problem, the
> > resulting strace output might be interesting.
> 
> This is the result of said strace. Server's auth.unix.gid was flushed,
> client reboots and auto-mounts the NFS-share:
> 
> | [ .. ]
> | read(12, "172.17.145.222:/mnt/data/exports/application:0x00000009\n", 4096) = 56
> | write(12, "172.17.145.222:/mnt/data/exports/application:0x0000000a\n", 56) = 56
> | read(4, "0\n", 2048)                    = 2
> | write(4, "0 1259227707 1 0 \n", 18)     = 18
> 
> Again i flushed auth.unix.gid and directly accessed a file as root from
> the client:
> 
> | read(4, "0\n", 2048)                    = 2
> | write(4, "0 1259227903 1 0 \n", 18)     = 18
> 
> This works as expected, file contents returned. Again i flushed
> auth.unix.gid and switched to the user with the mismatching uid on the
> server & client, accessed the exact same file directly:
> 
> | read(4, "1002\n", 2048)                 = 5
> | write(4, "1002 1259227918 \n", 17)      = -1 EINVAL (Invalid argument)
> 
> These two lines repeat at a very slow interval while the client retries:

OK, thanks.  Looking through the git logs....  Looks like this problem
was addressed recently in nfs-utils, by making mountd pass down a
zero-length list of gid's instead of just passing down a negative
response.  The patch went in between 1.1.3 and 1.1.4.

(Arguably maybe the kernel should also be modified to interpret a
negative response as a zero-length list.  I'd accept a patch.)

--b.

commit 86c3a79a108091fe08869a887438cc2d4e1126ed
Author: Neil Brown <neilb@suse.de>
Date:   Wed Aug 27 16:30:19 2008 -0400

    mount issue with Mac OSX and --manage-gids, client hangs
    
    Make sure are zero len group list is sent down to the
    kernel when the gids do not exist on the server.
    
    Tested-by: Alex Samad <alex-SGFoFqf0RKf0CCvOHzKKcA@public.gmane.org>
    Signed-off-by: Neil Brown <neilb@suse.de>
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index f555dcc..609c6e3 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -158,8 +158,10 @@ void auth_unix_gid(FILE *f)
 		qword_printint(f, ngroups);
 		for (i=0; i<ngroups; i++)
 			qword_printint(f, groups[i]);
-	}
+	} else
+		qword_printint(f, 0);
 	qword_eol(f);
+
 	if (groups != glist)
 		free(groups);
 }
