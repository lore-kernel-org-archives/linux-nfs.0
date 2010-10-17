Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:34552 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751526Ab0JQLvk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 17 Oct 2010 07:51:40 -0400
Received: by qwa26 with SMTP id 26so1113618qwa.19
        for <linux-nfs@vger.kernel.org>; Sun, 17 Oct 2010 04:51:40 -0700 (PDT)
Date: Sun, 17 Oct 2010 15:51:40 +0400
Message-ID: <AANLkTikOjYEBGJVHc7fKisNoC7OrJRjePuCcaNtPnHCy@mail.gmail.com>
Subject: Strange behaviour of NFS4ERR_MOVED and referrals
From: Pavel Strashkin <pavel.strashkin@nexenta.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi all,

I'm learning NFS4 "referral" feature.
I have 4 machines with installed Ubuntu 10.10 (kernel
2.6.35-22-generic): Server-A, Server-B, Server-C and Client-A.

Server-A is the main server in the "cluster" that provides NFS share
"/exports" with a single referral: "/exports/referral".
That referral points to 2 servers: Server-B and Server-C.

Client-A is the user of this referral.

When i mount "/exports" NFS share from Server-A on Client-A, i have no
issues and i can see "referral" directory. After that Client-A have an
access to that "referral" directory and can see files on Server-B
because Server-B the first server in referral list. NFS4ERR_MOVED
works as expected.

...now let's switch off Server-B...

When Server-B is down (dont forget, we had 2 servers in referral list)
and i'm trying to do "ls -l" for "referral" directory, the operation
hangs forever. If i kill -9 "ls" process and remount directory then it
automatically switches to Server-C (because Server-B is unreachabel).

The question: why there is no migration (fail-over? switch?) to
another server from referral list when share already mounted and
current server from referral list is down?

I looked at NFS kernel code and as i understand it keeps information
about FIRST valid server from referral list in inode. It keeps single
server information, not a whole list of servers (fs_locations). After
that all operations related to referral inode will be delegated to
that server.

RFC says that if client can not access to the first server in referral
list, it should try the next. One thing i dont undertand here - RFC
means "try next" when we do mount or when we're working with referral
inode?

P.S. i also triend another one situation: i removed referral on
Server-A and replace it by real directory called "referral". After
that client still trying to access to referral (share on Server-B),
but not real directory on Server-A. Seems like invalidation does not
work.
