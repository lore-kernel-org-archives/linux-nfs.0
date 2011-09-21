Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from talus.maths.usyd.edu.au ([129.78.68.1]:34763 "EHLO
	talus.maths.usyd.edu.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390Ab1IUFip (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Sep 2011 01:38:45 -0400
Date: Wed, 21 Sep 2011 15:38:33 +1000
From: paul.szabo@sydney.edu.au
Message-Id: <201109210538.p8L5cX2K030762@bari.maths.usyd.edu.au>
To: Trond.Myklebust@netapp.com
Subject: RE: Please support NSF squashing multiple groups
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480225@SACMVEXC2-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Dear Trond,

>>> ... It is too easy to fake a uid or a gid when you use a protocol that
>>> exposes them in clear on the network ...
>> Trivial to find out what they are, may not be so easy to inject them.
>
> If you are inside the network? All you need is a client and sufficient
> privileges to open a privileged port. ...

Inside "the network", but on the wrong subnet.

>> In terms of usurping UIDs, he is pretty much defeated ... rendered
>> harmless by root_squash. ...
>
> Ermm... If you can spoof any user (except root), then surely there are
> several alternatives open to you. ...

I am not worried about attackers getting access to the data of another
user, but about "getting root" on the server or another client:
  ... the attacker creating a setgid (group staff or disk or similar)
  /users/my/file is sufficient for a compromise ...
as mentioned in
http://www.spinics.net/lists/linux-nfs/msg23481.html

I am aware that the attacker could trojan the files of a user who is
known to log in as root, and so trap and reveal the root password;
or steal the Xauthority from such a user and inject keystrokes to a
rootly window.

> There are 2 solutions to that problem: either go the route of the
> rpc.ugidd daemon ...

Which is not present, does not seem supported on Debian. Also, reading
http://linuxmafia.com/pub/linux/suse-linux-internals/chapter20.html
it sounds like ugidd runs on the client not the server, so is unable to
provide the protection I want. Maybe using map_static would be the way
to go, but is also not supported on Debian.

And anyway this all seems to contradict Neil Brown's message
http://www.spinics.net/lists/linux-nfs/msg23488.html
earlier in this thread saying NFSv3 cannot possibly do things "right".

Cheers, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia
