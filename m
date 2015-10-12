Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:35192 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbbJLQtY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Oct 2015 12:49:24 -0400
Received: by igbkq10 with SMTP id kq10so76829341igb.0
        for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2015 09:49:23 -0700 (PDT)
Received: from localhost (dhcp-24-53-243-138.cable.user.start.ca. [24.53.243.138])
        by smtp.gmail.com with ESMTPSA id n3sm5156700iga.0.2015.10.12.09.49.23
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Oct 2015 09:49:23 -0700 (PDT)
From: Nick Bowler <nbowler@draconx.ca>
Date: Mon, 12 Oct 2015 12:48:56 -0400
To: linux-nfs@vger.kernel.org
Subject: PROBLEM: nfs I/O errors with sqlite applications
Message-ID: <20151012164846.GA5017@draconx.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I'm having a problem where, eventually, the nfs-mounted home directory
on one of my machines starts failing in a kind of weird way.  The issue
appears to affect only sqlite; I have two applications that I know of
which use it:

  - Firefox, where the symptom is that the browser just hangs randomly,
  - gmpc, which crashes immediately on startup with I/O error.

Once the issue occurs these applications remain permanently broken.
Since the latter is easier to test, I can run it in strace, and the
failing syscall seems to be:

  fcntl(7, F_SETLK, {type=F_RDLCK, whence=SEEK_SET, start=1073741824, len=1}) = -1 EIO (Input/output error)

When the issue occurs, the client dmesg log is full of messages of the form:

  [3441972.381211] NFS: v4 server returned a bad sequence-id error on an unconfirmed sequence ffff88007612ae20!

There are no unusual messages on the server.

Rebooting the client corrects the issue in the short term, but it seems
to re-occur after about 1 month of uptime.  This makes it difficult to
test anything.  So right now I have left the client in the broken state
in case there's something else I can try.

The client is running Linux 4.2, with approx. 38 days uptime.  The
server is running Linux 4.1.4, with 62 days uptime.

Let me know if you need any more info.

Thanks,
  Nick
