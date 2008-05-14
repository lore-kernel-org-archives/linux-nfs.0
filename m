From: "Alexander Borghgraef" <alexander.borghgraef.rma@gmail.com>
Subject: Nfs filesystem corruption(?) after kmail crash
Date: Wed, 14 May 2008 14:32:16 +0200
Message-ID: <9e8c52a20805140532w2bcfeff3n896fa5a9b0e82b5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:54525 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754358AbYENMcS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 May 2008 08:32:18 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1407593nfc.21
        for <linux-nfs@vger.kernel.org>; Wed, 14 May 2008 05:32:16 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I've been posting this on every linux support forum I thought
relevant, with no useful response. I suspect it's an nfs problem, so
now I'm trying this list. The problem is this: ever since upgrading
from Fedora 6 to 8, I've been experiencing periodic kmail/contact
crashes. After running for some time, kmail pops an error window:

  Error opening /home/myhome/Mail/sent-mail/cur; either this is not a
valid maildir folder, or you do not have
  sufficient access permissions.

Sent-mail is just an example, it happens to random mail directories.
Shortly after this, kmail crashes with the error message:

  KMail encountered a fatal error and will terminate now. The error
was: Could not sync maildir folder.

So I did an ls of an affected mail directory, which resides on an nfs
filesystem on a fileserver, and I found this rather disquieting
result:

  aborghgr@mypc~$ ls -l Mail/inbox/
  ls: cannot access Mail/inbox/cur: No such file or directory
  total 8
  d????????? ? ?        ?          ?                ? cur
  drwx------ 2 aborghgr slocate 4096 2005-07-08 13:23 new
  drwx------ 2 aborghgr slocate 4096 2008-04-24 10:24 tmp

The cur directory (or other files to which this has happened)is not
permanently lost: moving its parent directory for example restores all
of the files, and simply waiting also solves the problem. Still, it
makes working with kmail impossible, and also raises concerns about
the stability of the filesystem in general. The people at the kdepim
list said that a user-space program such as kmail could not possibly
corrupt the filesystem like that, so it has to be a bug in nfs. Any
ideas? I'm using Fedora 8, the 2.6.24.4-64.fc8 kernel and kmail 1.9.9
on kde 3.5.9-5.fc8. The nfs fileserver runs Fedora Core 3 with the
2.6.9-1.667 kernel (old machine).

--
Alex Borghgraef
