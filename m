Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:59090 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751689Ab1KJVLW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2011 16:11:22 -0500
Date: Thu, 10 Nov 2011 16:11:17 -0500
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] nfsidmap: Added -v flag
Message-ID: <20111110211117.GA2011@umich.edu>
References: <1320956785-18004-1-git-send-email-steved@redhat.com>
 <1320956785-18004-3-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1320956785-18004-3-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson wrote:

  To aid in debugging, the -v flag can now be specified
  on the command to enable verbose logging in both
  the nfsidmap command and libnfsidmap library routines.
  
  Signed-off-by: Steve Dickson <steved@redhat.com>
  ---
   utils/nfsidmap/nfsidmap.c   |   12 ++++++++++++
   utils/nfsidmap/nfsidmap.man |   15 ++++++++++++---
   2 files changed, 24 insertions(+), 3 deletions(-)
  
  diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
  index 134d9bc..d74189a 100644
  --- a/utils/nfsidmap/nfsidmap.c
  +++ b/utils/nfsidmap/nfsidmap.c
  @@ -12,6 +12,7 @@
   #include <syslog.h>
   #include "xlog.h"
   
  +int verbose = 0;
   /* gcc nfsidmap.c -o nfsidmap -l nfsidmap -l keyutils */
   
   #define MAX_ID_LEN   11
  @@ -108,6 +109,12 @@ int main(int argc, char **argv)
   	xlog_syslog(1);
   	xlog_stderr(0);
   
  +	if (argc > 1 && strcmp(argv[1], "-v") == 0) {
  +		verbose = 1;
  +		nfs4_set_debug(1, NULL);
  +		argc--, argv++;
  +	}
  +

Ugh.  Is there some reason not to use getopt() like all the other utils do?
