Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.mail.umich.edu ([141.211.14.82]:57785 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753205Ab1IZMYD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Sep 2011 08:24:03 -0400
Date: Mon, 26 Sep 2011 08:23:55 -0400
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] Add a check for libdevmapper.h
Message-ID: <20110926122355.GB12412@umich.edu>
References: <1317037317-4329-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1317037317-4329-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Steve Dickson wrote:

  When NFS v4.1 is enable, the libdevemapp.h header file has to exist.
  
  Signed-off-by: Steve Dickson <steved@redhat.com>
  ---
   configure.ac |    1 +
   1 files changed, 1 insertions(+), 0 deletions(-)
  
  diff --git a/configure.ac b/configure.ac
  index 80fb39d..572b33d 100644
  --- a/configure.ac
  +++ b/configure.ac
  @@ -80,6 +80,7 @@ AC_ARG_ENABLE(nfsv41,
   			AC_MSG_ERROR([NFS v4.1 is enabled but NFS v4 is not. Use --disable-nfsv41])
   		fi
   		BLKMAPD=blkmapd
  +   		AC_CHECK_HEADER(libdevmapper.h, , AC_MSG_ERROR([Cannot find libdevmapper.h header file. Try installing device-mapper-devel]))
   	else
   		enable_nfsv41=
   		BLKMAPD=

On Debian based systems it's libdevmapper-dev.

Did you get the patch I sent?  I added the check farther down, with the
other checks, and also checked for the library.
