Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from talus.maths.usyd.edu.au ([129.78.68.1]:53355 "EHLO
	talus.maths.usyd.edu.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754575Ab1HSWWE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Aug 2011 18:22:04 -0400
Date: Sat, 20 Aug 2011 08:21:54 +1000
From: paul.szabo@sydney.edu.au
Message-Id: <201108192221.p7JMLsQb005834@bari.maths.usyd.edu.au>
To: bfields@fieldses.org
Subject: Re: Please support NSF squashing multiple groups
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20110819192940.GB1641@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Dear Bruce,

>> NFS has always had the root_squash option, to protect against a remote
>> and possibly evil root. NFS should also protect all privileged, or at
>> least all root-equivalent, UIDs and GIDs. Many UNIX distributions have
>> root-equivalent GIDs, groups whose members could easily become root,
>> some listed in http://bugs.debian.org/299007#219 .
>
> Hm.  It depends on what you're using the exports for, I suppose.  If the
> server exports something it doesn't itself use for anything important
> then the server should be safe against clients.  The clients though may
> be able to attack each other if say /usr/bin is mounted over NFS and
> is writeable by some non-root group.  OK, I guess that's what you're
> saying.

Sorry, no.

There would be some protection if users could not log in to the server
or some clients. My setup includes user login access to the server and
to clients, so the attacker creating a setgid (group staff or disk or
similar) /users/my/file is sufficient for a compromise of the server or
any clients.

There would be some protection if the server or clients had the relevant
filesystems mounted nosuid or noexec, but in my setup users need to be
able to create setuid-to-themselves executables.

>> Currently, NFS has no ways to protect privileged UIDs and GIDs other
>> than root himself. Such options should be implemented, to make NFS
>> safer and more useful. As I understand it, the hold-up is not within
>> NFS code, but with kernel interfaces not supporting lists of squashed
>> entities. I am asking you to devise and implement such interfaces.
>
> That's not a small project, so we'd need a volunteer.  As Neil says
> kerberos might also help.

I realize this is not an easy project.

I will investigate NFSv4 and kerberos.

Thanks, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia
