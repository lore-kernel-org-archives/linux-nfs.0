Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:52052 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753634AbcCABBV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Feb 2016 20:01:21 -0500
Date: Mon, 29 Feb 2016 20:01:20 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jason L Tibbitts III <tibbs@math.uh.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS: nfs4_reclaim_open_state: Lock reclaim failed! log spew
Message-ID: <20160301010120.GB11952@fieldses.org>
References: <ufafuwhlr72.fsf@epithumia.math.uh.edu>
 <20160225195827.GC23315@fieldses.org>
 <ufaegbvdslg.fsf@epithumia.math.uh.edu>
 <20160301004844.GA11952@fieldses.org>
 <ufay4a3c938.fsf@epithumia.math.uh.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <ufay4a3c938.fsf@epithumia.math.uh.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 29, 2016 at 06:53:15PM -0600, Jason L Tibbitts III wrote:
> >>>>> "JBF" == J Bruce Fields <bfields@fieldses.org> writes:
> 
> JBF> Argh, it's all encrypted, so we all we have to go on is the size of
> JBF> the request and reply:
> 
> Yeah, I'm not sure how to get around that.  I know tshark can take a
> keytab, but the user's key is in the kernel keyring and I'm not at all
> sure how to dig it out (assuming I even can).  But if there's something
> I can do, I can try.
> 
> I could switch to krb5i or plain krb for a while if that would be
> useful, except that the clients would prefer krb5p if it's exported, and
> if I stop exporting it then existing mounts break....  I'd have to
> schedule downtime and kick everyone off, which I could do if it would
> help.

I believe the order of flavors in the sec= option is the order they're
given to the client, so reversing it might cause new clients to make a
different choice--but I'm not actually sure of the logic there.

> 
> JBF> The best you could do is capture all traffic and throw away all but
> JBF> the last few seconds (see the ring buffer stuff in tshark) and
> JBF> write a script that kills the capture as soon as it notices you've
> JBF> hit this condition.
> 
> If I knew how to detect the condition, though, I have a feeling that
> would be enough information to track down the bug anyway.
> 
> Also, I'd have to do this for a couple of hundred clients.  Ugh.

Yeah, don't worry about it, I was just thinking aloud.

--b.
