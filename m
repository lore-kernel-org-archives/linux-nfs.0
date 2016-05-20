Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:33142 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961AbcETUiu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 May 2016 16:38:50 -0400
Received: by mail-io0-f178.google.com with SMTP id t40so66671283ioi.0
        for <linux-nfs@vger.kernel.org>; Fri, 20 May 2016 13:38:50 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 20 May 2016 16:38:49 -0400
Message-ID: <CAN-5tyE4tqNpUnQHYpNnbC-MANRKXFm0TttF9dVPOBh9MP9gyw@mail.gmail.com>
Subject: questions about open state recovery and open owner seq_id management
From: Olga Kornievskaia <aglo@umich.edu>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

I’m seeing a client behavior that I can’t explain the reason behind
(i.e. spec) so want to ask for help.

Question #1: Should a reclaim of open state handle BAD_SEQID the same
way the normal open handles BAD_SEQID (which is: it just retries). I
can see that during recovery we might not want the recovery to be
trying forever and that’s why we fail? I don’t see anything in the
spec that talk about this…

Question #2: Incrementing seqid of open owner. I see that when LOCK
receives an error BAD_STATEID/ADMIN_REVOKED, sequence isn’t
incremented and (recovery) OPEN is sent with the same seqid. The code
explicitly sets seqid unconfirmed. Again, I don’t know where to look
in the spec for something like this. What happens is that server
replies back with BAD_SEQID.

So normally, when an open fails with BAD_SEQID the client retries but
combine it with a LOCK that failed with BAD_STATEID. Then it leads to
the application failing with “bad file descriptor” because after
receiving an error for the lock and trying to do open recovery, the
code doesn’t increment seqid and open fails with BAD_SEQID and we
don’t retry the open. So now we don’t have a file descriptor and we
fail the lock.

Thank you.
