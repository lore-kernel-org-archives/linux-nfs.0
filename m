Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:18181 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752910AbaGJUBl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 16:01:41 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: rpciod/1: page allocation failure. order:2, mode:0x20'
Date: Thu, 10 Jul 2014 20:01:39 +0000
Message-ID: <1FAA3C78-BBFA-4186-A25A-0D4E97609934@netapp.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi

A customer of ours, running a 2.6.32-431.5.1.el6.x86_64 kernel NFS client, is hittng the "rpciod/1: page allocation failure. order:2, mode:0x20", but only with NFSv3 hard mounts (not soft mounts), and not with NFSv4 (same application, same client hardware). Has anyone hit this issue with RHEL6.5?  Any ideas on why NFSv3 would trigger this error and not NFSv4?

I see in Red Hat Bugzilla 767127 - swapper: page allocation failure. order:1, mode:0x20 (edit) that a similar issue was solved by setting vm.zone_reclaim_mode = 1 which used to be the default.  Adjusting the vm.min_free_kbytes higher may also help.  Any side effects or issues with these settings?

Any info appreciated

—>Andy


