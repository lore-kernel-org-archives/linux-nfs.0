Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.12.86]:42103 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751876Ab1KLTPb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Nov 2011 14:15:31 -0500
Date: Sat, 12 Nov 2011 14:15:26 -0500
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] nfsidmap: Added -v and -t flags
Message-ID: <20111112191526.GB25581@umich.edu>
References: <1321113346-10106-1-git-send-email-steved@redhat.com>
 <1321113346-10106-3-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1321113346-10106-3-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson wrote:

  +	arg = malloc(sizeof(char) * strlen(argv[optind]) + 1);
  +	strcpy(arg, argv[optind]);

strdup() would have been simpler.  But don't re-do it just for this.
