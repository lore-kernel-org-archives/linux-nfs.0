Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36790 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225AbbLZL7f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Dec 2015 06:59:35 -0500
Received: by mail-pf0-f173.google.com with SMTP id 65so45798471pff.3
        for <linux-nfs@vger.kernel.org>; Sat, 26 Dec 2015 03:59:35 -0800 (PST)
Received: from [10.1.5.97] ([164.100.31.82])
        by smtp.googlemail.com with ESMTPSA id ry1sm70024284pab.30.2015.12.26.03.59.33
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1/SSLv3 cipher=OTHER);
        Sat, 26 Dec 2015 03:59:33 -0800 (PST)
To: linux-nfs@vger.kernel.org
From: dE <de.techno@gmail.com>
Subject: How do you get /proc/fs/nfs/exports to populate?
Message-ID: <567E812E.2040204@gmail.com>
Date: Sat, 26 Dec 2015 17:29:42 +0530
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi!
     I'm running nfs-utils without init script or systemd unit assistance.

Since I'm using nfsv4, I'm eliminating the need to start mountd.

Now if mountd is gone, who populates /proc/fs/nfs/exports?

But even after running mountd (after an exportfs -a), this file still 
does not have any entries.

Running rpc.nfsd with --

rpc.nfsd -d --syslog --port 10000

rpc.mountd runs without any arguments.
