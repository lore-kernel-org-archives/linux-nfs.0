From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [RFC PATCH 0/3] Introduce two new mount stats commands
Date: Fri, 16 Apr 2010 13:54:21 -0400
Message-ID: <4BC8A44D.1070205@RedHat.com>
References: <1271430621-8663-1-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19370 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753871Ab0DPRyW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 13:54:22 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o3GHsMjP016535
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:54:22 -0400
Received: from badhat.bos.devel.redhat.com (vpn-237-52.phx2.redhat.com [10.3.237.52])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o3GHsLlp002740
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:54:22 -0400
In-Reply-To: <1271430621-8663-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/16/2010 11:10 AM, Steve Dickson wrote:
> These patches install the mountstats and nfsiostat commands
> as well as creates and installed their man pages. 
> 
> Steve Dickson (3):
>   Introduce man page for the mountstats command
>   Introduce man page for the nfsiostats command
>   Add autoconf support for mountstats and nfsiostats
> 
>  configure.ac                    |    2 +
>  tools/Makefile.am               |    2 +-
>  tools/mountstats/Makefile.am    |   13 +++++++
>  tools/mountstats/mountstats.man |   32 ++++++++++++++++++
>  tools/nfs-iostat/Makefile.am    |   13 +++++++
>  tools/nfs-iostat/nfsiostat.man  |   70 +++++++++++++++++++++++++++++++++++++++
>  6 files changed, 131 insertions(+), 1 deletions(-)
>  create mode 100644 tools/mountstats/Makefile.am
>  create mode 100644 tools/mountstats/mountstats.man
>  create mode 100644 tools/nfs-iostat/Makefile.am
>  create mode 100644 tools/nfs-iostat/nfsiostat.man
Committed and pushed...

steved.
