Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from talus.maths.usyd.edu.au ([129.78.68.1]:57336 "EHLO
	talus.maths.usyd.edu.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344Ab1I3EJI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Sep 2011 00:09:08 -0400
Received: from smtpdoor@localhost by talus.maths.usyd.edu.au (8.14.3/8.5)
	id p8U48jmE006725 for linux-nfs@vger.kernel.org; Fri, 30 Sep 2011 14:08:45 +1000
Received: from bari.maths.usyd.edu.au (psz@bari.maths.usyd.edu.au) [129.78.69.145]
	by siv.maths.usyd.edu.au via smtpdoor V27.1
	id 6724 for linux-nfs@vger.kernel.org; Fri, 30 Sep 2011 14:08:45 +1000
Date: Fri, 30 Sep 2011 14:08:45 +1000
From: paul.szabo@sydney.edu.au
Message-Id: <201109300408.p8U48jDJ002867@bari.maths.usyd.edu.au>
Received: from psz@localhost by bari.maths.usyd.edu.au (8.14.3/8.5/Submit)
	id p8U48jDJ002867 for linux-nfs@vger.kernel.org; Fri, 30 Sep 2011 14:08:45 +1000
To: linux-nfs@vger.kernel.org
Subject: Re: Please support NSF squashing multiple groups
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Dear all,

I wrote recently:

  Seems that the mountd option --manage-gids handles the secondary groups
  only. I still do not quite understand why mountd (with that or another
  option) cannot handle the primary GID also, setting it to the GID
  corresponding to the UID on the server; and maybe even "squash" any UIDs
  in a table similar to idmap, or simply squash UIDs less than UID_MIN
  (squash directly, without any kernel interaction). Could you please tell
  me whether those are conceptually possible?

Silly me, should have looked myself! Now I understand that things are
not "done" in mountd, but are in the kernel: the use of those
/proc/net/rpc/%s/channel things is not in the mountd binary, but in the
kernel linux-source-2.6.32/net/sunrpc/svcauth_unix.c . No use setting
things up in mountd, if the kernel does not bother using them.

So it remains that for security, I would need NFSv4 with kerberos.

Thanks for all your help, and apologies for my stubbornness.

Cheers, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia
