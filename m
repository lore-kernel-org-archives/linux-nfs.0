From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC PATCH 0/3] Introduce two new mount stats commands
Date: Fri, 16 Apr 2010 12:19:09 -0400
Message-ID: <4BC88DFD.2020604@oracle.com>
References: <1271430621-8663-1-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:51178 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758049Ab0DPQUd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Apr 2010 12:20:33 -0400
In-Reply-To: <1271430621-8663-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This looks like a good starting point.  Thanks.

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

On 04/16/2010 11:10 AM, Steve Dickson wrote:
> These patches install the mountstats and nfsiostat commands
> as well as creates and installed their man pages.
>
> Steve Dickson (3):
>    Introduce man page for the mountstats command
>    Introduce man page for the nfsiostats command
>    Add autoconf support for mountstats and nfsiostats
>
>   configure.ac                    |    2 +
>   tools/Makefile.am               |    2 +-
>   tools/mountstats/Makefile.am    |   13 +++++++
>   tools/mountstats/mountstats.man |   32 ++++++++++++++++++
>   tools/nfs-iostat/Makefile.am    |   13 +++++++
>   tools/nfs-iostat/nfsiostat.man  |   70 +++++++++++++++++++++++++++++++++++++++
>   6 files changed, 131 insertions(+), 1 deletions(-)
>   create mode 100644 tools/mountstats/Makefile.am
>   create mode 100644 tools/mountstats/mountstats.man
>   create mode 100644 tools/nfs-iostat/Makefile.am
>   create mode 100644 tools/nfs-iostat/nfsiostat.man

-- 
chuck[dot]lever[at]oracle[dot]com
