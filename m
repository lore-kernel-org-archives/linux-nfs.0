Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.math.uh.edu ([129.7.128.33]:33580 "EHLO mx2.math.uh.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750763AbcCABDd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Feb 2016 20:03:33 -0500
From: Jason L Tibbitts III <tibbs@math.uh.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS: nfs4_reclaim_open_state: Lock reclaim failed! log spew
References: <ufafuwhlr72.fsf@epithumia.math.uh.edu>
	<20160225195827.GC23315@fieldses.org>
	<ufaegbvdslg.fsf@epithumia.math.uh.edu>
	<20160301004844.GA11952@fieldses.org>
	<ufay4a3c938.fsf@epithumia.math.uh.edu>
	<20160301010120.GB11952@fieldses.org>
Date: Mon, 29 Feb 2016 19:03:31 -0600
In-Reply-To: <20160301010120.GB11952@fieldses.org> (J. Bruce Fields's message
	of "Mon, 29 Feb 2016 20:01:20 -0500")
Message-ID: <ufapovfc8m4.fsf@epithumia.math.uh.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>>>>> "JBF" == J Bruce Fields <bfields@fieldses.org> writes:

JBF> I believe the order of flavors in the sec= option is the order
JBF> they're given to the client, so reversing it might cause new
JBF> clients to make a different choice--but I'm not actually sure of
JBF> the logic there.

I've found it not to actually be stable; different Linux versions will
do different things.  But then, almost all of the desktops are now
running a single OS release so unless it's simply random, that should be
good enough.  I'll add krb5 to the exports and try to catch this again.

 - J<
