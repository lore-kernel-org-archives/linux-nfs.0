Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout1.thls.bbc.co.uk ([132.185.240.36]:58744 "EHLO
	mailout1.thls.bbc.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755300Ab0LHUUy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Dec 2010 15:20:54 -0500
Date: Wed, 8 Dec 2010 20:20:09 +0000
From: David Flynn <davidf@rd.bbc.co.uk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: David Flynn <davidf@rd.bbc.co.uk>, linux-nfs@vger.kernel.org
Subject: Re: NFSv4: "Viminfo file is not writable" -- stat(2) uid/gid
 incorrect
Message-ID: <20101208202009.GH20844@rd.bbc.co.uk>
References: <20101208153340.GD20844@rd.bbc.co.uk>
 <1291835999.3067.13.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1291835999.3067.13.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

* Trond Myklebust (Trond.Myklebust@netapp.com) wrote:
> You really should file a bug with the vim folks on this. Checking
> permissions using the above scheme is inherently racy (and quite
> frankly, wrong). See the caveats in the 'access()' manpage for details.

> If you want to find out if the file can be modified, then the only race
> free way to do so, is to try to open() it.

Yes, i intend to do this -- what is more, they already have the file
open (they do, open(), stat()).  I havn't looked at the vim source yet
to spot quite why they think this is a good idea.  (If they really are
trying to manually spot permissions, it misses so many other routes,
acls, etc).

> > === truncate ===
> > === remote unlink, create ===
> > === stat(1) ===
> >   File: `.file'
> >   Size: 4               Blocks: 0          IO Block: 1048576 regular file
> > Device: 18h/24d Inode: 5678963     Links: 1
> > Access: (0644/-rw-r--r--)  Uid: ( 1179/  davidf)   Gid: ( 1000/      rd)
> > Access: 2010-11-29 16:50:03.414109000 +0000
> > Modify: 2010-11-29 17:00:17.698839000 +0000
> > Change: 2010-11-29 17:00:17.698839000 +0000
> > === stat,open,stat,close,stat ===
> > stat(".file"...), st_uid=1179, st_gid=1000
> > open(".file", O_RDONLY) = 3
> > stat(".file"...), st_uid=4294967294, st_gid=4294967294
> > close(3)
> > stat(".file"...), st_uid=4294967294, st_gid=4294967294
> > === stat(1) ===
> >   File: `.file'
> >   Size: 7               Blocks: 2          IO Block: 1048576 regular file
> > Device: 18h/24d Inode: 5678906     Links: 1
> > Access: (0644/-rw-r--r--)  Uid: (4294967294/ UNKNOWN)   Gid: (4294967294/ UNKNOWN)
> > Access: 2010-11-29 17:00:18.059076000 +0000
> > Modify: 2010-11-29 17:00:18.064360000 +0000
> > Change: 2010-11-29 17:00:18.064360000 +0000
> 
> Your idmapper appears to be mapping the user to 'nobody', which is
> usually a sign that it is misconfigured. It may, however, also mean that
> the username (or groupname) is missing in /etc/passwd (or /etc/groups).

I don't think this is the case. I performed a network trace of the
transaction and i can see that for all the calls with a user/group in
they refer to me (davidf@rd.bbc.co.uk, rd@rd.bbc.co.uk).

I also checked the local idmapper to see what it thought of things, and
it doesn't get an upcall to map this request, so values have been
previously cached.

Also, the thing about this "race" is that it is very very slow.  its
utterly reliable.  running vim on "host-B" does not have to occur while
it runs on "host-A", nor does it seem to need to happen soon
after/before "host-A" quits/starts vim.

> I've no idea how to check the Solaris idmapper configuration, but on
> Linux you want to look at /etc/idmapd.conf (specifically the 'Domain'
> line).

That is correct as far as i can tell.  The first part of the transaction
is OK, however, it fails as soon as stat() is called after open().

I've just sanitized a network capture of the following.  I've removed
anything sensitive to what i hope are just the calls related to
the above (please excuse any tcp lost segments due to this).  It is
available at:
  ftp://ftp.kw.bbc.co.uk/davidf/priv/nfs-staterror-20101208-clean.pcap

bash <<EOF
> ssh lxg1 "rm $PWD/.file; echo barbar >$PWD/.file" ; \
> sleep 10 ; \
> echo === 'stat(1)' === ; \
> stat .file ; \
> echo === stat,open,stat,close,stat === ; \
> ~/test-stat-open-stat .file ; \
> echo === 'stat(1)' === ; \
> stat .file
> EOF
=== truncate ===
=== remote unlink, create ===
=== stat(1) ===
  File: `.file'
  Size: 4               Blocks: 2          IO Block: 1048576 regular file
Device: 18h/24d Inode: 7111198     Links: 0
Access: (0644/-rw-r--r--)  Uid: ( 1179/  davidf)   Gid: ( 1000/      rd)
Access: 2010-12-08 19:38:16.289020000 +0000
Modify: 2010-12-08 19:38:16.312946000 +0000
Change: 2010-12-08 19:38:26.870908000 +0000
=== stat,open,stat,close,stat ===
stat("..file"...), st_uid=1179, st_gid=1000
open(".file", O_RDONLY) = 3
stat("..file"...), st_uid=4294967294, st_gid=4294967294
close(3)
stat("..file"...), st_uid=4294967294, st_gid=4294967294
=== stat(1) ===
  File: `.file'
  Size: 7               Blocks: 2          IO Block: 1048576 regular file
Device: 18h/24d Inode: 7111201     Links: 1
Access: (0644/-rw-r--r--)  Uid: (4294967294/ UNKNOWN)   Gid: (4294967294/ UNKNOWN)
Access: 2010-12-08 19:38:26.884045000 +0000
Modify: 2010-12-08 19:38:26.891030000 +0000
Change: 2010-12-08 19:38:26.891030000 +0000


Transcript of the network capture:

time = 0s [pkt1] ".file" is created with FH:
  nfs.fhandle ==
  01:54:00:1e:00:00:00:02:00:0a:00:00:00:6c:82:1e:57:b5:6a:e5:00:0a:00:00:00:00:00:02:69:96:a5:a0:00:00:00:00

  "foo" is written to it, commited, closed
time = 0.0498s [pkt14]

sleep 10 seconds

ssh to remote system, "rm $PWD/.file; echo barbar >$PWD/.file"

sleep 10 seconds

time=20.617s [pkt15] /usr/bin/stat .file
  call uses:
  nfs.fhandle ==
  01:54:00:1e:00:00:00:02:00:0a:00:00:00:6c:82:1e:57:b5:6a:e5:00:0a:00:00:00:00:00:02:69:96:a5:a0:00:00:00:00

time=20.639s [pkt redacted]  (~/test-stat-open-stat loads via nfs)

time=20.730s [pkt17] ~/test-stat-open-stat open()'s ".file"
  GETFH returns
  nfs.fhandle ==
  01:54:00:1e:00:00:00:02:00:0a:00:00:00:6c:82:21:26:3e:e3:78:00:0a:00:00:00:00:00:02:69:96:a5:a0:00:00:00:00

time=20.731s [pkt19] ~/test-stat-open-stat close()'s ".file"
time=20.732s [pkt21] /usr/bin/stat .file

I can't quite discriminate which calls after ~/test-stat-open-stat
(packets 17,19,21) were caused by which process (ie,
~/test-stat-open-stat or /usr/bin/stat), in earlier parts i could see
the PATH search for "stat" occurring.

I can't see any calls that don't use my textual owner / group.  Can you
confirm this?

Kind regards,

..david
