Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34142 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751632Ab1KNPG7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Nov 2011 10:06:59 -0500
Message-ID: <4EC12E8F.3000109@RedHat.com>
Date: Mon, 14 Nov 2011 10:06:55 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jim Rees <rees@umich.edu>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] nfsidmap: Added -v and -t flags
References: <1321113346-10106-1-git-send-email-steved@redhat.com> <1321113346-10106-3-git-send-email-steved@redhat.com> <20111112191526.GB25581@umich.edu>
In-Reply-To: <20111112191526.GB25581@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/12/2011 02:15 PM, Jim Rees wrote:
> Steve Dickson wrote:
> 
>   +	arg = malloc(sizeof(char) * strlen(argv[optind]) + 1);
>   +	strcpy(arg, argv[optind]);
> 
> strdup() would have been simpler.  But don't re-do it just for this.
We should also be checking for failure as well... Here's how I took care of it:

-       arg = malloc(sizeof(char) * strlen(argv[2]) + 1);
-       strcpy(arg, argv[2]);
+       if (verbose)
+               nfs4_set_debug(verbose, NULL);
+
+       key = strtol(argv[optind++], NULL, 10);
+
+       arg = strdup(argv[optind]);
+       if (arg == NULL) {
+               xlog_err("strdup failed: %m");
+               return 1;
+       }

steved.
