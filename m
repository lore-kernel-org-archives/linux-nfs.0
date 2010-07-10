From: NFS Troubs <nfstroubs@gmail.com>
Subject: file on NFS incorrectly reported as missing
Date: Sat, 10 Jul 2010 17:01:14 +0200
Message-ID: <AANLkTinZV9XoTDPDhqP3kF1xcl2S_rALIAWjp3U3BprJ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41860 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773Ab0GJPBQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 10 Jul 2010 11:01:16 -0400
Received: by wyf23 with SMTP id 23so2383638wyf.19
        for <linux-nfs@vger.kernel.org>; Sat, 10 Jul 2010 08:01:15 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have got four webservers and one fileserver, all running Karmic and
kernel 2.6.31-14-generic #48-Ubuntu SMP Fri Oct 16 14:05:01 UTC 2009
x86_64 GNU/Linux.

A folder on the fileserver on an EXT3 file system has been exported
using NFSv3 with these options: rw,async,no_subtree_check
and mounted on all four webservers with these options:
defaults,rsize=32768,wsize=32768,noatime

The webservers run Apache+PHP+APC. Some php-files include other
php-files from the nfs mount, and are requested by users very
frequently (~ 100 times per second). Sometimes but not always if I
alter an included php-file using FTP (the FTP server is ProFTPD and
runs on the fileserver), the file seems missing:

user@webserver1: ~ $ ls --full-time -al /path/to/included/file.php
ls: cannot access /path/to/included/file.php: No such file or directory

I can repeat this command for hours, but the file keeps missing. Until
I query the directory:

user@webserver1: ~ $ ls --full-time -al /path/to/included/ | grep file
-rwxr-xr-x 1 1002 1002 14294 2010-07-04 21:11:30.000000000 +0200 file.php

and then the first command also works.

Any suggestion would be welcome.
