From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/2] nfs-utils: Add nfsidmap (take 2)
Date: Mon, 22 Nov 2010 12:15:41 -0500
Message-ID: <4CEAA53D.8020509@RedHat.com>
References: <1290188343-10579-1-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43219 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750790Ab0KVRPm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Nov 2010 12:15:42 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id oAMHFgFa001176
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 22 Nov 2010 12:15:42 -0500
In-Reply-To: <1290188343-10579-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/19/2010 12:39 PM, Steve Dickson wrote:
> The is a re-post of Bryan origin patches that added
> in the new nfsidmap program. I tweaked them in the
> following ways:
> 
> Rename the binary from nfs.idmap to nfsidmap to maintain
> conformity with the rest of the binary names.
> 
> Since do not like to commit patches that do not compile,
> I moved all the autoconfig setting to the second patch.
> Then I re-wrote Trond's patch to not compile the nfsidmap
> code when libnfsidmap does not have the updated support
> instead of failing the compilation.
> 
> Bryan Schumaker (1):
>   Add the new nfsidmap program
> 
> Steve Dickson (1):
>   Enable nfsidmap to compile
> 
>  aclocal/keyutils.m4         |   11 ++++
>  aclocal/libnfsidmap.m4      |    4 ++
>  configure.ac                |    7 +++
>  utils/Makefile.am           |    3 +
>  utils/nfsidmap/Makefile.am  |    9 +++
>  utils/nfsidmap/nfsidmap.c   |  118 +++++++++++++++++++++++++++++++++++++++++++
>  utils/nfsidmap/nfsidmap.man |   60 ++++++++++++++++++++++
>  7 files changed, 212 insertions(+), 0 deletions(-)
>  create mode 100644 aclocal/keyutils.m4
>  create mode 100644 utils/nfsidmap/Makefile.am
>  create mode 100644 utils/nfsidmap/nfsidmap.c
>  create mode 100644 utils/nfsidmap/nfsidmap.man
> 
Committed...

steved.
