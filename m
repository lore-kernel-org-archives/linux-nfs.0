Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.math.uh.edu ([129.7.128.32]:56484 "EHLO mx1.math.uh.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751072AbcCAAxS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Feb 2016 19:53:18 -0500
From: Jason L Tibbitts III <tibbs@math.uh.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS: nfs4_reclaim_open_state: Lock reclaim failed! log spew
References: <ufafuwhlr72.fsf@epithumia.math.uh.edu>
	<20160225195827.GC23315@fieldses.org>
	<ufaegbvdslg.fsf@epithumia.math.uh.edu>
	<20160301004844.GA11952@fieldses.org>
Date: Mon, 29 Feb 2016 18:53:15 -0600
In-Reply-To: <20160301004844.GA11952@fieldses.org> (J. Bruce Fields's message
	of "Mon, 29 Feb 2016 19:48:44 -0500")
Message-ID: <ufay4a3c938.fsf@epithumia.math.uh.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>>>>> "JBF" == J Bruce Fields <bfields@fieldses.org> writes:

JBF> Argh, it's all encrypted, so we all we have to go on is the size of
JBF> the request and reply:

Yeah, I'm not sure how to get around that.  I know tshark can take a
keytab, but the user's key is in the kernel keyring and I'm not at all
sure how to dig it out (assuming I even can).  But if there's something
I can do, I can try.

I could switch to krb5i or plain krb for a while if that would be
useful, except that the clients would prefer krb5p if it's exported, and
if I stop exporting it then existing mounts break....  I'd have to
schedule downtime and kick everyone off, which I could do if it would
help.

JBF> The best you could do is capture all traffic and throw away all but
JBF> the last few seconds (see the ring buffer stuff in tshark) and
JBF> write a script that kills the capture as soon as it notices you've
JBF> hit this condition.

If I knew how to detect the condition, though, I have a feeling that
would be enough information to track down the bug anyway.

Also, I'd have to do this for a couple of hundred clients.  Ugh.

 - J<
