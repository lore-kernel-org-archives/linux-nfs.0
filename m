Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from talus.maths.usyd.edu.au ([129.78.68.1]:60339 "EHLO
	talus.maths.usyd.edu.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751510Ab1ITWsk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2011 18:48:40 -0400
Received: from smtpdoor@localhost by talus.maths.usyd.edu.au (8.14.3/8.5)
	id p8KMmLPG010287 for linux-nfs@vger.kernel.org; Wed, 21 Sep 2011 08:48:21 +1000
Received: from bari.maths.usyd.edu.au (psz@bari.maths.usyd.edu.au) [129.78.69.145]
	by siv.maths.usyd.edu.au via smtpdoor V27.1
	id 10285 for linux-nfs@vger.kernel.org; Wed, 21 Sep 2011 08:48:21 +1000
Date: Wed, 21 Sep 2011 08:48:21 +1000
From: paul.szabo@sydney.edu.au
Message-Id: <201109202248.p8KMmLaI008501@bari.maths.usyd.edu.au>
Received: from psz@localhost by bari.maths.usyd.edu.au (8.14.3/8.5/Submit)
	id p8KMmLaI008501 for linux-nfs@vger.kernel.org; Wed, 21 Sep 2011 08:48:21 +1000
To: linux-nfs@vger.kernel.org
Subject: Re: Please support NSF squashing multiple groups
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Dear all,

I wrote about some security issues with NFS, about protecting against
privileged UIDs and GIDs, like root_squash protects against root.

Your advice was to use NFSv4 with kerberos authentication. I now
succeeded in setting that up on a test system; though not as simple as
should be, it seems to work as expected. The changes required for use
are non-trivial, so I will not immediately be able to use it.

Seems that the mountd option --manage-gids handles the secondary groups
only. I still do not quite understand why mountd (with that or another
option) cannot handle the primary GID also, setting it to the GID
corresponding to the UID on the server; and maybe even "squash" any UIDs
in a table similar to idmap, or simply squash UIDs less than UID_MIN
(squash directly, without any kernel interaction). Could you please tell
me whether those are conceptually possible?

Thanks, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia
