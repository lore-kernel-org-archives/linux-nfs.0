Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f54.google.com ([74.125.82.54]:37433 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932877AbbBDPQK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Feb 2015 10:16:10 -0500
Received: by mail-wg0-f54.google.com with SMTP id b13so2250476wgh.13
        for <linux-nfs@vger.kernel.org>; Wed, 04 Feb 2015 07:16:09 -0800 (PST)
Received: from [192.168.1.2] ([59.89.23.52])
        by mx.google.com with ESMTPSA id pp10sm3134870wjc.31.2015.02.04.07.16.04
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Feb 2015 07:16:05 -0800 (PST)
Message-ID: <54D237A5.1050302@gmail.com>
Date: Wed, 04 Feb 2015 20:45:49 +0530
From: dE <de.techno@gmail.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Cant get to export this particular directory.
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi.

I'm trying to export a particular directory with these parameters --

/home/test/huge/temp_small/subdir 
fc00::5000/124(ro,anonuid=1000,anongid=1000,subtree_check)

For all subdirectories in temp_small, the client fails to mount saying 
permission denied.

mount.nfs: access denied by server while mounting.....

For any other place it works.

And because rpc.mountd has no logging features, I got no idea what's 
happening.
