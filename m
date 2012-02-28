Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.12.86]:58250 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752141Ab2B1PJc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Feb 2012 10:09:32 -0500
Date: Tue, 28 Feb 2012 10:09:23 -0500
From: Jim Rees <rees@umich.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jeff Layton <jlayton@redhat.com>, Harshula <harshula@redhat.com>,
        Steve Dickson <SteveD@redhat.com>, NeilBrown <neilb@suse.de>,
        linux-nfs@vger.kernel.org
Subject: Re: "Using NFS over UDP on high-speed links such as Gigabit can
 cause silent data corruption."
Message-ID: <20120228150923.GA13432@umich.edu>
References: <1330406521.9157.16.camel@serendib>
 <20120228065218.7e110936@tlielax.poochiereds.net>
 <20120228124646.GA2528@umich.edu>
 <BC3988C4-CC1A-4DFA-89AE-7046C674A873@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <BC3988C4-CC1A-4DFA-89AE-7046C674A873@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:

  As above, most other uses of UDP do not involve large packets.  But I
  wonder if it is appropriate for us to suggest a change in the default
  setting.

A minute is certainly too long.  Just a guess, but 4 seconds seems
appropriate to me.  That's good enough for gigabit ethernet.  Anyone running
fragmented 10G networks gets what they deserve.

Yes, you can have more than four seconds of data in flight at moderate
speeds, but unless something is terribly wrong the fragments should come in
very close together.
