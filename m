Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:43125 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755311Ab1HFMjC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Aug 2011 08:39:02 -0400
Date: Sat, 6 Aug 2011 08:38:58 -0400
From: Jim Rees <rees@umich.edu>
To: Luk Claes <luk@debian.org>
Cc: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] start-statd: Use bash as -p is no POSIX
Message-ID: <20110806123858.GA20169@merit.edu>
References: <1312624768-2394-1-git-send-email-luk@debian.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1312624768-2394-1-git-send-email-luk@debian.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Luk Claes wrote:

  sh -p is not guaranteed to be provided by POSIX shells. dash for instance
  does not provide this, so use bash explicitly.

That's pretty funny.  The script requires a posix shell, which bash isn't by
default, so it provides an undocumented (in my ubuntu man page) option to
force bash into compliance.  Since the option itself isn't posix, we now
require the use of this non-posix shell so we can guarantee posix
compliance.
