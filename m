Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:47034 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753369Ab2DYAnf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Apr 2012 20:43:35 -0400
Date: Tue, 24 Apr 2012 20:43:32 -0400
From: Jim Rees <rees@umich.edu>
To: Super Bisquit <superbisquit@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfs-utils-1.2.5 getpagesize error in
 utils/blkmpd/device-process.c
Message-ID: <20120425004332.GA20453@umich.edu>
References: <CA+WntOuEeVYNJbmeS9vqkTJt8+sTAc=6zDT757+KTGu7LY5eUg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CA+WntOuEeVYNJbmeS9vqkTJt8+sTAc=6zDT757+KTGu7LY5eUg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Super Bisquit wrote:

  device-process.c: In function ‘decode_blk_volume’:
  device-process.c:299: error: ‘PAGE_SIZE’ undeclared (first use in this function)
  device-process.c:299: error: (Each undeclared identifier is reported only once
  device-process.c:299: error: for each function it appears in.)
  make: *** [device-process.o] Error 1
  root@dookie-bomb:/tmp/nfs-utils-1.2.5/utils/blkmapd#

Your nfs-utils is out of date.  The fix for this is commit fdc6e7ec.  Repo
is at git://git.linux-nfs.org/projects/steved/nfs-utils.git .
