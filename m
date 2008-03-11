From: "Fletcher Mattox" <fletcher-NZpS4cJIG2HvQtjrzfazuQ@public.gmane.org>
Subject: mail corruption with async mounts NFSv3
Date: Tue, 11 Mar 2008 13:59:43 -0500
Message-ID: <200803111859.m2BIxiKC001883@cs.utexas.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from shadowfax.cs.utexas.edu ([128.83.120.180]:59858 "EHLO
	shadowfax.cs.utexas.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874AbYCKTpo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Mar 2008 15:45:44 -0400
Received: from cs.utexas.edu (fletcher-NZpS4cJIG2HvQtjrzfazuQ@public.gmane.org [128.83.139.9])
	by shadowfax.cs.utexas.edu (8.14.2/8.14.2) with ESMTP id m2BIxi75013011
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Tue, 11 Mar 2008 13:59:44 -0500 (CDT)
Received: (from fletcher@localhost)
	by cs.utexas.edu (8.14.2/8.14.2/Submit) id m2BIxiKC001883
	for linux-nfs@vger.kernel.org; Tue, 11 Mar 2008 13:59:44 -0500 (CDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi

We deliver mail via NFS to a NetApp file server.  After many trouble
free years, we are suddenly and frequently seeing corrupted mailboxes.
We usually see a series of NUL bytes (10 to 2000+) prepended to the
message (i.e. immediately in front of the From_ line).  Our local
delivery agent is procmail.  It is configured to lock files via
dotlock only, no kernel based file locking.  After obtaining a lock,
procmail does this, before writing:

        fd   = open(mailbox,O_WRONLY|O_APPEND|O_CREAT,perm);
        last = lseek(fd,(off_t)0,SEEK_END);

My experience with procmail has been positive.  It goes to great
trouble to do correct locking over NFS (within the limits of the
protocol, of course).

We use NFSv3 on a 2.6.19.1 kernel with this entry in /etc/mtab:

    filer4b:/vol/vol18/v18q001 /v/filer4b/v18q001 nfs \
      rw,tcp,rsize=8192,wsize=8192,intr,grpid,quota,retry=2,\
      addr=128.83.x.x 0 0

I will admit to being surprised to learn that async mounts are the
default.  I was fooled by the absence of an "async" above.  Could that
be the problem?  I guess if the corruption were infrequent, isolated
events, I would be tempted to write it off to async an async mount.
But this happens consistently (several times a day on a 12,000
message/day mail server).

We can identify no changes on the client or server which might account
for this.  Very frustrating.  Even a complete backup/restore on the
client from a couple weeks prior to the first reported incident had
no effect.  And our NetApp administrator tells me nothing changed on
the server.

I am not a NetApp administrator, but looking at the server side,
I find this in NetApp's documentation (Solution ID: ntapcs6821),
wherein it states:

        NetApp filers only support synchronous mounts. If
        an NFS client is mounted to a filer volume or qtree
        asynchronously, the client may or may not mount the
        filer volume. If the mount is successful, the NFS
        mount to the filer will be synchronous.
          [ ... snip ... ]
        * Using an asynchronous NFS mount could lead to data
          inconsistency or corruption
        
        * Asynchronous NFS mounts may be desired for better
          write performance, but NetApp filers generally
          exhibit very good NFS write performance with
          synchronous NFS due to the way the NVRAM works

This document is three years old, so it may no longer be accurate,
but it does seem apropos to our situation.  And sure enough, if
I add a "sync" flag to the above mount, the corruption goes away.
Of course, we then suffer nearly a tenfold(!) decrease in performance.

So my questions are: What will the linux automounter/mount do when
informed by an NFS server that async mounts are not supported?  Will it
return an error to the user, or log a diagnostic message somewhere?
It seems, based on our experience, that there is no error, the mount
succeeds, and the writes will proceed asynchronously.  Is this true?

However, something about the above explanation of our problem does not
ring true.  First of all, we have been using async mounts for years
without any problem.  But more importantly, why do we see corruption
so consistently?  If async mounts are to blame, wouldn't we see
corruption only when the server crashed? (which has not happened)

Does anyone have another explanation?  (And thanks for reading
this far!)

Fletcher
