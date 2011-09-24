Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49762 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752603Ab1IXARZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2011 20:17:25 -0400
Received: by wyg34 with SMTP id 34so4430452wyg.19
        for <linux-nfs@vger.kernel.org>; Fri, 23 Sep 2011 17:17:24 -0700 (PDT)
Date: Fri, 23 Sep 2011 17:17:24 -0700
Message-ID: <CAOB=RsJUwPsU4gjnW208wYJ-VCsbRovyg3xEfHn2boWwGicZ=w@mail.gmail.com>
Subject: NFSv4 read delegation
From: Sukwoo Kang <sukwoo.kang@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello, I'm trying to find out how NFSv4 client can get read
delegation. I'm using separate RHEL6 machines (2.6.32-71.el6.x86_64)
as server and client respectively.

If I use pynfs, I can see server gives out read delegation. Basically
pynfs sends these RPCs to server - open (create), open_confirm, open,
open_confirm.

On real NFS client,

If I do 'cat <file>' twice, client does not get read delegation.
	- (nfs4state.c)
	- if (!cb_up || !sop->so_confirmed)
		goto out;
	- Here sop->so_confirmed is 0.

If I open the existing file with O_RDONLY twice (i.e., open, not close
it and open again), client sends open only once to server.
	- So here also sop->so_confirmed is 0. Delegation is not sent out.
(I've added more debug messages shown in below.)

2011-09-23T22:41:44.642938+02:00 int002st001 kernel: NFSD:
nfs4_open_delegation enter
2011-09-23T22:41:44.642942+02:00 int002st001 kernel: NFSD: nfs4_open_claim_null
2011-09-23T22:41:44.643853+02:00 int002st001 kernel: NFSD: cb_up=1,
sop->so_confirmed=0
2011-09-23T22:41:44.643857+02:00 int002st001 kernel: NFSD: either
callback is not up or not open confirmed
2011-09-23T22:41:44.643858+02:00 int002st001 kernel: NFSD:
nfs4_open_delegation exit

If I open the existing file with O_RDWR and then open it with
O_RDONLY, I can see "sop->so_confirmed = 1", but setlease failed.
	- I think it is because there is writer on this file.

2011-09-23T11:23:28.116280+02:00 int002st001 kernel: NFSD:
nfs4_open_delegation enter
2011-09-23T11:23:28.116717+02:00 int002st001 kernel: NFSD: nfs4_open_claim_null
2011-09-23T11:23:28.117879+02:00 int002st001 kernel: NFSD: cb_up=1,
sop->so_confirmed=1
2011-09-23T11:23:28.117887+02:00 int002st001 kernel: NFSD alloc_init_deleg
2011-09-23T11:23:28.117889+02:00 int002st001 kernel: NFSD: setlease
failed [-11], no delegation
2011-09-23T11:23:28.119101+02:00 int002st001 kernel: NFSD:
close_delegation dp ffff88006ba05e60
2011-09-23T11:23:28.119109+02:00 int002st001 kernel: NFSD: freeing dp
ffff88006ba05e60
2011-09-23T11:23:28.120050+02:00 int002st001 kernel: NFSD:
nfs4_open_delegation exit

What is missing here? I will appreciate any advice. Thank you.
	
Regards,
Sukwoo Kang
