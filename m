Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34339 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753324Ab1KNVMJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Nov 2011 16:12:09 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pAELC9D7020927
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 14 Nov 2011 16:12:09 -0500
Message-ID: <4EC18428.5020007@RedHat.com>
Date: Mon, 14 Nov 2011 16:12:08 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/2] Added error logging and verbosity flag (ver #2)
References: <1321113346-10106-1-git-send-email-steved@redhat.com>
In-Reply-To: <1321113346-10106-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/12/2011 10:55 AM, Steve Dickson wrote:
> Here the second version of this patch series. In this
> version, as suggested, nfsidmap now uses getopt()
> to parse the command line arguments. While I was
> there I so convert the timeout value to be specified
> by '-t' flag instead of being the last value on the
> command line.
> 
> I also prove this new debugging is helpful and needed,
> because it help me find a bug in the libnfsidmap lib.
> 
> Steve Dickson (2):
>   nfsidmap: Added Error Logging
>   nfsidmap: Added -v and -t flags
> 
>  utils/nfsidmap/Makefile.am  |    2 +-
>  utils/nfsidmap/nfsidmap.c   |   77 +++++++++++++++++++++++++++++++++---------
>  utils/nfsidmap/nfsidmap.man |   26 ++++++++++----
>  3 files changed, 79 insertions(+), 26 deletions(-)
> 
Both patches committed....

steved.
