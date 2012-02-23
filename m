Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:48152 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753413Ab2BWBHK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Feb 2012 20:07:10 -0500
Received: by eekc4 with SMTP id c4so177470eek.19
        for <linux-nfs@vger.kernel.org>; Wed, 22 Feb 2012 17:07:09 -0800 (PST)
MIME-Version: 1.0
From: Louie <snikrep@gmail.com>
Date: Wed, 22 Feb 2012 17:06:49 -0800
Message-ID: <CAMgFM3CXWEXqo+Nr1tt6XS6XrhJVfW9a5Dx=iSACriCOxfXjkw@mail.gmail.com>
Subject: v4recovery client id lockup
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We have a weird, intermittent issue with NFS that I've been trying to
track down for the past 6 months. This is on NFS v4, mounted over SSH,
with Centos 6.2 as client/server.

Periodically, when running a client-side command that reads a large amount of
files (e.g. converting 2000 small picture files to another format over
NFS), our server will completely lock up for a period of time. ATOP
shows 50-90% IO activity on the sda drive (root system, but not the
shared NFS area where the files are actually located).

I've finally tracked down the activity to the
/var/lib/nfs/v4recovery directory. One of the client ID directories
gets created/deleted over and over again (same name each time) -
enough to completely lock up the system. If I sit on the directory
while this is happening and do "ls" commands over and over, you can
see it disappear and appear ("ls -i" shows new inode numbers).

The strange thing is that this is periodic, and if you simply
kill the client process and restart, everything often works smoothly. The
actual server IO activity seems to be coming from the journal (what
appears in iostat), but it's only writing/rewriting the empty client
ID directories (the size of the activity shows 0.0 kb/s).

I've searched everywhere for info on this directory and trying to
debug this stuff in general and come up empty, sorry if this has been
covered before.

Appreciate ANY help, this has been driving me completely crazy.
