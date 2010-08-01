Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:52264 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751879Ab0HAHrc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Aug 2010 03:47:32 -0400
Received: by iwn7 with SMTP id 7so2936092iwn.19
        for <linux-nfs@vger.kernel.org>; Sun, 01 Aug 2010 00:47:31 -0700 (PDT)
Date: Sun, 1 Aug 2010 19:47:31 +1200
Message-ID: <AANLkTinZN+uhDShmg8aKiSEA8M3pr_RXu58OyyLPapxm@mail.gmail.com>
Subject: statd: server localhost not responding, timed out; lockd: cannot
	monitor <client>
From: Dan Wallis <mrdanwallis@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello list :)

This is my first post here, so if it's in the wrong place, or if I've
not read the appropriate documentation, please feel free to send me a
link to the relevant bits. I've tried searching the archives, and the
internet at large, but haven't yet come across anything that's helped.

Our NFS-shared file-system is locking up.

At the time, there are a lot of processes in "disk sleep" state, and
the load averages on our machines sky-rocket. The machines are
responsive on SSH, but our the majority of our websites
(apache+mod_php) just hang, as does our email system (exim+dovecot).
Any websites which don't require write access to the file-system
continue to operate.

The load averages continue to rise until some kind of time-out is
reached, but for at least 10-15 minutes. I've seen load averages over
800, yet the machines are still responsive for actions which don't
require writing to the shared file-system.

I've been investigating a variety of options, which have all turned
out to be red-herrings: nagios, proftpd, bind, cron tasks.

I'm seeing these messages in the file server's system log:

Jul 30 09:37:17 fs0 kernel: [1810036.560046] statd: server localhost
not responding, timed out
Jul 30 09:37:17 fs0 kernel: [1810036.560053] nsm_mon_unmon: rpc
failed, status=-5
Jul 30 09:37:17 fs0 kernel: [1810036.560064] lockd: cannot monitor node2
Jul 30 09:38:22 fs0 kernel: [1810101.384027] statd: server localhost
not responding, timed out
Jul 30 09:38:22 fs0 kernel: [1810101.384033] nsm_mon_unmon: rpc
failed, status=-5
Jul 30 09:38:22 fs0 kernel: [1810101.384044] lockd: cannot monitor node0

Software involved:
VMWare, Debian lenny (64bit), ancient Red Hat (32 bit) (version 7 I
believe), Debian etch (32bit)
NFS, apache2+mod_php, exim, dovecot, bind, amanda, proftpd, nagios,
cacti, drbd, heartbeat, keepalived, LVS, cron, ssmtp, NIS, svn,
puppet, memcache, mysql, postgres
Joomla!, Magento, Typo3, Midgard, Symfony, custom php apps

So far, I've spent a lot of time trying to reproduce the problem, but
haven't been able to do so.


If you've any ideas, please let me know. :)



Cheers
Dan
