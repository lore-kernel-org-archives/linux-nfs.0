Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:49531 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537Ab1HVQOP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Aug 2011 12:14:15 -0400
Date: Mon, 22 Aug 2011 12:14:13 -0400
From: Jim Rees <rees@umich.edu>
To: paul.szabo@sydney.edu.au
Cc: linux-nfs@vger.kernel.org
Subject: Re: Please support NSF squashing multiple groups
Message-ID: <20110822161413.GE2477@merit.edu>
References: <201108190032.p7J0W3ZX030679@bari.maths.usyd.edu.au>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201108190032.p7J0W3ZX030679@bari.maths.usyd.edu.au>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Paul, it's good to hear from you.  Been about 12 years.

AUTH_SYS provides what some people call "pretend security."  The server
enforces a security policy based on user and group IDs.  But it only
pretends to enforce the policy, because it allows clients to break the rules
if they want.

Some people claim this is useless, and AUTH_SYS should go away, to be
replaced by "none" or "kerberos."  I disagree.  It's useful for preventing
mistakes among a group of users who trust each other but sometimes get
sloppy.  My home network would be a good example.  A compute cluster might
be another.

I do find root_squash useful but I'm not sure there's much point in adding
more squash options.  For one thing it might lull people into thinking
they're getting something more than just pretend security.  If you have
users who might try to break in to a machine by setting setgid bits, then
AUTH_SYS is not for you.
