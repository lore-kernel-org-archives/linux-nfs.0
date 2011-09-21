Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from talus.maths.usyd.edu.au ([129.78.68.1]:52394 "EHLO
	talus.maths.usyd.edu.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752033Ab1IUAKD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2011 20:10:03 -0400
Date: Wed, 21 Sep 2011 10:09:51 +1000
From: paul.szabo@sydney.edu.au
Message-Id: <201109210009.p8L09pgs026367@bari.maths.usyd.edu.au>
To: Trond.Myklebust@netapp.com
Subject: RE: Please support NSF squashing multiple groups
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B48011F@SACMVEXC2-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Dear Trond,

> That's a model which is incompatible with the way many people use
> the AUTH_SYS authentication model.

That is why I only propose (hope for) mountd options which might be
used by some people, and others might leave turned off.

> ... It is too easy to fake a uid or a gid when you use a protocol
> that exposes them in clear on the network ...

Trivial to find out what they are, may not be so easy to inject them.

---

> ... I don't at all understand your threat model. You appear to be
> worried about a threat where a user can somehow usurp gids but not
> uids on the client.

I am worried about an attacker being able to "do anything" on the
client (having "cracked root" on it).

In terms of usurping UIDs, he is pretty much defeated: the only
privileged UID is root, rendered harmless by root_squash. (Beware
that other UIDs e.g. bin or sys may be dangerous on some systems:
root_squash as currently implemented is incomplete, insecure.)

There is currently no such protection for usurping GIDs, and some
(e.g. staff for Debian, or disk shadow etc) are privileged and
root-equivalent. We need protection, similar to root_squash.

Cheers, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia
