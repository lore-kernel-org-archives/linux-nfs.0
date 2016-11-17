Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.math.uh.edu ([129.7.128.32]:38334 "EHLO mx1.math.uh.edu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754518AbcKQRIi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 17 Nov 2016 12:08:38 -0500
From: Jason L Tibbitts III <tibbs@math.uh.edu>
To: bfields@fieldses.org (J. Bruce Fields)
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS: nfs4_reclaim_open_state: Lock reclaim failed! log spew
References: <ufafuwhlr72.fsf@epithumia.math.uh.edu>
        <20160225195827.GC23315@fieldses.org>
        <ufaegbvdslg.fsf@epithumia.math.uh.edu>
        <20160301004844.GA11952@fieldses.org>
        <ufay4a3c938.fsf@epithumia.math.uh.edu>
        <20160301010120.GB11952@fieldses.org>
        <ufapovfc8m4.fsf@epithumia.math.uh.edu>
        <ufa1syb402e.fsf@epithumia.math.uh.edu>
        <20161117163101.GA19161@fieldses.org>
Date: Thu, 17 Nov 2016 11:08:35 -0600
In-Reply-To: <20161117163101.GA19161@fieldses.org> (J. Bruce Fields's message
        of "Thu, 17 Nov 2016 11:31:01 -0500")
Message-ID: <ufa1sya11bg.fsf@epithumia.math.uh.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>>>>> "JBF" == J Bruce Fields <bfields@fieldses.org> writes:

JBF> So, you're using NFSv4.1 or 4.2, and the server thinks that the
JBF> client has reused a (slot, sequence number) pair, but the server
JBF> doesn't have a cached response to return.

Thanks for the reply.  Sadly I don't understand all of it, but...

JBF> Hard to know how that happened, and it's not shown in the below.
JBF> Sounds like a bug, though.

Yeah, I only found the problem after it was already happening, so
obviously the beginning of the process is missing.  And sadly it's not
something I can easily repeat, so short of running some continuous
package capture (which would be hard since once this starts the traffic
volume is huge) there's no easy way to see it.

Is there any state on either the client or server that I could inspect
which might give any hints?  I can add that to my notes in case this
problem happens again.

JBF> Recent clients will use sec=krb5 for certain state-related
JBF> operations even if you mount with sec=sys, so it's still possible
JBF> it could be involved here.

On the server, the involved filesystem isn't exported with any sec=
options, in case it matters.

JBF> The SEQ4_STATUS_RECALLABLE_STATE_REVOKED flag set in the OPEN
JBF> replies is also a sign something's gone wrong.  Apparently the
JBF> server thinks the client has failed to return a delegation.

I can't imagine how that might have happened.  There is nothing else
NFS-related in the client's log besides the spew and that final line.
There are some automount complaints about the user accessing directories
that aren't in the map sources, and the usual random gssproxy noise
which was fixed in Fedora 24.

Currently the system is stable; it hasn't been rebooted since the
problem occurred.  Everything cleared up once I was able to unmounted
the problematic filesystem.

 - J<
