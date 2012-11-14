Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f46.google.com ([209.85.219.46]:41831 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753176Ab2KNNi5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Nov 2012 08:38:57 -0500
Received: by mail-oa0-f46.google.com with SMTP id h16so380415oag.19
        for <linux-nfs@vger.kernel.org>; Wed, 14 Nov 2012 05:38:57 -0800 (PST)
MIME-Version: 1.0
From: =?UTF-8?B?xYF1a2FzeiBUYXN6?= <lukasz@tasz.eu>
Date: Wed, 14 Nov 2012 14:38:26 +0100
Message-ID: <CAGRr-NiRkkhoVG4ss5WG7RXXOUWQ5dcOaVAxbQ2yA2c1NbPjKw@mail.gmail.com>
Subject: nfs performance - idea.
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I would like to consult some idea with you,

Problem:
I have two processes which are doing some actions and one of the
action is done on a shared file system.
Issue is that this thing could be done only by one process, and for
this issue, locking mechanism is implemented.
Problem is that while one process is releasing lock, second one is
informed that file processing is finished, but unfortunately files
does not exists in context of second process.
Two processes are executed on two different hosts. NFS share is
mounted in a standard way, no special flag.
Problem I guess is with caches, lookupcache=none solves the problem,
but also causes others :) - performance.

I know, it not possible to have all things at once - no complains.
But simple idea is that inside second process after notification that
files are generated execute touch function on directory which holds
files,
This will cause unnecessary update of modification date, but as a side
effect I noticed  that also file gets visible immediately on client
hosts.

That's why my question is if this is expected and reasonable behaviour?
At the end I'm looking for kind of 'sync' command which will cause
synchronization of directories content inside client and server
something like flush() - but in NFS it's more complex.


thanks in advance for help,

regards
Lukasz



-- 
Łukasz Tasz
