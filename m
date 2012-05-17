Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.82]:41516 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750835Ab2EQLxj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 May 2012 07:53:39 -0400
Date: Thu, 17 May 2012 07:53:30 -0400
From: Jim Rees <rees@umich.edu>
To: Mike Frysinger <vapier@gentoo.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] osd_login: fix DESTDIR install
Message-ID: <20120517115330.GA3733@umich.edu>
References: <1337232243-18088-1-git-send-email-vapier@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1337232243-18088-1-git-send-email-vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Mike Frysinger wrote:

  diff --git a/utils/osd_login/Makefile.am b/utils/osd_login/Makefile.am
  index adc493a..c85584c 100644
  --- a/utils/osd_login/Makefile.am
  +++ b/utils/osd_login/Makefile.am
  @@ -1,12 +1,11 @@
   ## Process this file with automake to produce Makefile.in
   
  -OSD_LOGIN_FILES= osd_login
  -
  -EXTRA_DIST= $(OSD_LOGIN_FILES)
  +# These scripts go in /sbin (not /usr/sbin), and that cannot be
  +# overriden at config time.
  +sbindir = /sbin

You misspelled "overridden."  Yes, I know you just copied this line from
mount/Makefile.am, but there is no sense compounding the error.

Also it might be worth mentioning in the comment why we have this
restriction.
