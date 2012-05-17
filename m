Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.82]:60732 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752510Ab2EQL4q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 May 2012 07:56:46 -0400
Date: Thu, 17 May 2012 07:56:37 -0400
From: Jim Rees <rees@umich.edu>
To: NeilBrown <neilb@suse.de>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: ANNOUNCE: nfs-utils-1.2.6 released.
Message-ID: <20120517115637.GB3733@umich.edu>
References: <4FB159DA.2070800@RedHat.com>
 <20120517164420.3fe761a5@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120517164420.3fe761a5@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NeilBrown wrote:

  On Mon, 14 May 2012 15:15:38 -0400 Steve Dickson <SteveD@redhat.com> wrote:
  
  > New Features in this release:
  >    * The addition the nfsdcld daemon
  >    * The addition of the osd_login script which is mandated by the
  >          pnfs-objects standard
  
  Don't you hate it when people don't bother to test all your -rc's, then
  report bugs against your final release?  Me too.
  
    mkdir /tmp/dest
    make DESTDIR=/tmp/dest install
  
  fails because it tries to install osd_login in /tmp/dest/sbin/osd_login
  without first creating /tmp/dest/sbin.  All other required directories get
  created first.
  
  This patch - stealing an idea from utils/mount - seem to fix it.

Please see my comment in response to Mike Frysinger's similar patch.

Date: Thu, 17 May 2012 07:53:30 -0400
From: Jim Rees <rees@umich.edu>
Subject: Re: [PATCH] osd_login: fix DESTDIR install
To: Mike Frysinger <vapier@gentoo.org>
Cc: linux-nfs@vger.kernel.org

You misspelled "overridden."  Yes, I know you just copied this line from
mount/Makefile.am, but there is no sense compounding the error.

Also it might be worth mentioning in the comment why we have this  
restriction.
