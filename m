Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([83.163.148.79]:44070 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754004Ab1HDKaV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Aug 2011 06:30:21 -0400
Date: Thu, 4 Aug 2011 12:30:19 +0200
From: Frank van Maarseveen <frankvm@frankvm.com>
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: [NLM] fcntl(F_SETLKW) yields -ENOLCK when grace period expires.
Message-ID: <20110804103018.GA11727@janus>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Both client- and server run 2.6.39.3, NFSv3 over UDP (without the
relock_filesystem patch proposed earlier).

A second client has an exclusive lock on a file on the server. The
client under test calls fcntl(F_SETLKW) to wait for the same exclusive
lock. Wireshark sees NLM V4 LOCK calls resulting in NLM_BLOCKED.

Next the server is rebooted. The second client recovers the lock
correctly. The client under test now receives NLM_DENIED_GRACE_PERIOD for
every NLM V4 LOCK request resulting from the waiting fcntl(F_SETLKW). When
this changes to NLM_BLOCKED after grace period expiration the fcntl
returns -ENOLCK ("No locks available.") instead of continuing to wait.

server:/proc/locks shows two entries for the file after the -ENOLCK. When
the second client gives up its lock because the program running there
is killed one entry in server:/proc/locks remains indefinately: as a
result no NFS client can lock the file anymore.

-- 
Frank
