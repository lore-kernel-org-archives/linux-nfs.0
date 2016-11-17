Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:18044 "HELO
        discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S1751212AbcKQU25 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Nov 2016 15:28:57 -0500
From: Andrew W Elble <aweits@rit.edu>
To: Jason L Tibbitts III <tibbs@math.uh.edu>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
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
        <ufa1sya11bg.fsf@epithumia.math.uh.edu>
Date: Thu, 17 Nov 2016 15:22:14 -0500
In-Reply-To: <ufa1sya11bg.fsf@epithumia.math.uh.edu> (Jason L. Tibbitts, III's
        message of "Thu, 17 Nov 2016 11:08:35 -0600")
Message-ID: <m2fump3lhl.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I've found this extremely useful on clients in tracking down 'lost' delegations.

echo "error != 0" | tee /sys/kernel/debug/tracing/events/nfs4/nfs4_delegreturn_exit/filter

...and then look in here:

cat /sys/kernel/debug/tracing/trace

(YMMV, not sure if this is going to work on your distro, debugfs etc)

There's still work to be done with nfsd4_delegreturn()
and revoked delegations serverside (as well as killing fh_verify() per
Bruce's earlier suggestions)

We've recently seen the server recall a delegation, revoke it, and then have the
client try to return it much later (because of an unknown slowness
issue) -- after the file had been deleted at the server.

Jason L Tibbitts III <tibbs@math.uh.edu> writes:

>>>>>> "JBF" == J Bruce Fields <bfields@fieldses.org> writes:
>
> JBF> So, you're using NFSv4.1 or 4.2, and the server thinks that the
> JBF> client has reused a (slot, sequence number) pair, but the server
> JBF> doesn't have a cached response to return.
>
> Thanks for the reply.  Sadly I don't understand all of it, but...
>
> JBF> Hard to know how that happened, and it's not shown in the below.
> JBF> Sounds like a bug, though.
>
> Yeah, I only found the problem after it was already happening, so
> obviously the beginning of the process is missing.  And sadly it's not
> something I can easily repeat, so short of running some continuous
> package capture (which would be hard since once this starts the traffic
> volume is huge) there's no easy way to see it.
>
> Is there any state on either the client or server that I could inspect
> which might give any hints?  I can add that to my notes in case this
> problem happens again.
>
> JBF> Recent clients will use sec=krb5 for certain state-related
> JBF> operations even if you mount with sec=sys, so it's still possible
> JBF> it could be involved here.
>
> On the server, the involved filesystem isn't exported with any sec=
> options, in case it matters.
>
> JBF> The SEQ4_STATUS_RECALLABLE_STATE_REVOKED flag set in the OPEN
> JBF> replies is also a sign something's gone wrong.  Apparently the
> JBF> server thinks the client has failed to return a delegation.
>
> I can't imagine how that might have happened.  There is nothing else
> NFS-related in the client's log besides the spew and that final line.
> There are some automount complaints about the user accessing directories
> that aren't in the map sources, and the usual random gssproxy noise
> which was fixed in Fedora 24.
>
> Currently the system is stable; it hasn't been rebooted since the
> problem occurred.  Everything cleared up once I was able to unmounted
> the problematic filesystem.
>
>  - J<
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
