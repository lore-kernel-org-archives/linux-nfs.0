Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fn.samba.org ([216.83.154.106]:52926 "EHLO lists.samba.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750866Ab0GWCNB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 22:13:01 -0400
Content-Type: text/plain; charset=us-ascii
Message-ID: <19528.64159.999224.437890@samba.org>
Date: Fri, 23 Jul 2010 12:12:47 +1000
To: "Ted Ts'o" <tytso@mit.edu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Jeremy Allison <jra@samba.org>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, Volker.Lendecke@sernet.de,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        Jan Engelhardt <jengelh@medozas.de>,
        David Howells <dhowells@redhat.com>, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended file stats available [ver #6]
In-Reply-To: <20100723012130.GD16373@thunk.org>
References: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
	<20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
	<30448.1279800887@redhat.com>
	<E1Obuiy-00C9jr-Al@intern.SerNet.DE>
	<AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com>
	<E1Obxpd-00CRIo-SF@intern.SerNet.DE>
	<AANLkTimwIq0pBhCeOjOVjB0yeM3JHOvzVoj9M4ui6al9@mail.gmail.com>
	<20100722162712.GB10352@jeremy-laptop>
	<AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
	<19528.60019.28495.655512@samba.org>
	<20100723012130.GD16373@thunk.org>
Reply-To: tridge@samba.org
From: tridge@samba.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Ted,

 > Does it literally mean "file creation time" in terms of when the OS
 > created the file, or does it mean "file" in the sense of
 > application contents.  For example, if an application edits the
 > file and saves it out using "write file to foo.new; sync; rename
 > foo to foo.bak; rename foo.new to foo", should the creation time
 > for the newly written file "foo" be the time when the editor saved
 > out the file (i.e., when "foo.new" was created), or copied from the
 > original file "foo"'s creation time.

In Windows this is can be controlled by applications, but it also is
done at the filesystem level in NTFS using a technique that Microsoft
call "File System Tunneling". If you create a file with the same name
within a short time (default 15s and settable in the registry) of when
the file previously existed then it will get the same CreationTime as
the previous file.

For details see http://support.microsoft.com/kb/172190

Some applications also do this regardless of the registry setting for
MaximumTunnelEntryAgeInSeconds. They use the ability to set the
CreationTime to get the same behaviour.

Cheers, Tridge
