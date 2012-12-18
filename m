Return-Path: linux-nfs-owner@vger.kernel.org
Received: from woodlands.midnighthax.com ([93.89.81.115]:44539 "EHLO
	woodlands.midnighthax.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755252Ab2LRUJS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Dec 2012 15:09:18 -0500
Date: Tue, 18 Dec 2012 19:42:51 +0000
From: Keith Edmunds <kae@midnighthax.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS access slow
Message-ID: <20121218194251.5bf674ff@ws.the.cage>
In-Reply-To: <20121218185006.GA14716@fieldses.org>
References: <20121218155248.49dfa1fd@kae.tiger-computing.wbp>
	<20121218185006.GA14716@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> What are your disks?

They are Enterprise Nearline 6Gb/s SAS drives in an Infortrend disk array.

>  How exactly are you getting those numbers?
> (Literally, step-by-step, what commands are you running?)

Using postmark:

pm> set location /mnt/tmp
pm> set size 10000 10000000
pm> run

The only difference is the 'set location' line, which points to either the
NFS mountpoint or the local mountpoint.

A test using dd ("dd if=/dev/zero of=/mnt/tmp bs=1M count=8192") gave a
difference of about five times faster for direct access versus access via
NFS.

> What kernel version?

3.2

> Note loopback-mounts (client and server on same machine) aren't really
> fully supported.

OK, I wasn't aware of that. We were only testing that way to try to
eliminate switches, cables, etc. I've just run a test from another server,
both connected via 10G links, and I'm getting a read speed of just under
20BM/s and a write speed of 52MB/s.
