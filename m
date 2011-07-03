Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:49990 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754407Ab1GCOLo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Jul 2011 10:11:44 -0400
Date: Sun, 3 Jul 2011 10:11:34 -0400
From: Jim Rees <rees@umich.edu>
To: Luk Claes <luk@debian.org>
Cc: NeilBrown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Do not segfault because of kernel version
Message-ID: <20110703141134.GA10071@merit.edu>
References: <1309617149-3993-1-git-send-email-luk@debian.org>
 <20110703150421.2db09d94@notabene.brown>
 <4E100E17.5000304@debian.org>
 <20110703130237.GA9889@merit.edu>
 <4E106A56.1050802@debian.org>
 <20110703132605.GC9889@merit.edu>
 <4E106E91.8080208@debian.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E106E91.8080208@debian.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Luk Claes wrote:

  > Yes, just return UINT_MAX.  Fix the other error return too, the one where
  > uname fails.  And put in a comment if you can briefly summarize Linus's
  > argument.
  
  I thought that a real error like uname failing should still get the
  'wrong' return 0, no?

No.  As I read it, Linus argues that you should only run the backward
compatibility code path when you know you're running an older kernel.  If
you don't know, then you should assume you're running a newer kernel.
