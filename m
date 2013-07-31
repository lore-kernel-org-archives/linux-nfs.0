Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f195.google.com ([209.85.217.195]:62978 "EHLO
	mail-lb0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756380Ab3GaMMk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Jul 2013 08:12:40 -0400
Received: by mail-lb0-f195.google.com with SMTP id v1so194401lbd.10
        for <linux-nfs@vger.kernel.org>; Wed, 31 Jul 2013 05:12:37 -0700 (PDT)
MIME-Version: 1.0
From: Abhijeet Rastogi <abhijeet.1989@gmail.com>
Date: Wed, 31 Jul 2013 17:41:57 +0530
Message-ID: <CACXxYfy6ySZOLTRGWfZjnozHP5irHa9N=DS=3AUH8RWgUtY35Q@mail.gmail.com>
Subject: Bug: nfsiostat fails to parse file /proc/self/mountstats in some cases
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

So, this is what I'm observing.

$ sudo nfsiostat
Traceback (most recent call last):
  File " in="" line="" module="" nfsiostat="" sbin="" usr="">
iostat_command(prog)
  File "/usr/sbin/nfsiostat", line 587, in iostat_command
    devices = list_nfs_mounts(origdevices, mountstats)
  File "/usr/sbin/nfsiostat", line 490, in list_nfs_mounts
    stats.parse_stats(descr)
  File "/usr/sbin/nfsiostat", line 179, in parse_stats
    self.__parse_rpc_line(words)
  File "/usr/sbin/nfsiostat", line 163, in __parse_rpc_line
    self.__rpc_data[op] = [long(word) for word in words[1:]]
ValueError: invalid literal for long() with base 10: 'device'

This happens because it's unexpected for nfsiostat to find line "no
device mounted on /sys/kernel/debug with fstype debugfs" in
/proc/self/mountstats. http://pb.abhijeetr.com/UREA

For now, I added

        if line.startswith("no device mounted"):
            continue

to fix the issue in parse_stats_file function. http://pb.abhijeetr.com/HUXO

Please ask if any more info is required. What's the best way to handle
it so that it can be added to upstream code?

--
Regards,
Abhijeet Rastogi (shadyabhi)
http://blog.abhijeetr.com
