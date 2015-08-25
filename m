Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:33520 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865AbbHYUY0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2015 16:24:26 -0400
Received: by iods203 with SMTP id s203so201621257iod.0
        for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2015 13:24:26 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 25 Aug 2015 16:24:25 -0400
Message-ID: <CAN-5tyFs3j2tNqm4rgsWrzO9KcFDQBfCrtNG7TNgMHrTzs9p5w@mail.gmail.com>
Subject: evict inode + new open race
From: Olga Kornievskaia <aglo@umich.edu>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

I have brought up earlier an existence of a race between evict inode
and an open where a new open happens after a delegation was removed
from the inode but the rpc tasks/network packets of DELEGRETURN and
OPEN arrive at the server in reverse order (OPEN before DELEGRETURN).
This particular case can be 'handled' by the server. However, there is
a different race that can't be.

There is a race between an ACCESS call and a DELEGRETURN. If a cached
open is used but we need to check permissions, then ACCESS code will
go on the wire. If at the same time the evict inode process is
happening, ACCESS code is returned and DELEGRETURN leaves the client
without an open stateid or delegation stateid. There might be a race
between a DELEGRETURN and an OPEN when it's just cached open and
permissions aren't checked.

I noticed that before evict inode is called, the VFS layer will first
call drop_inode() function (if implemented) and based on that decision
it will instead of evicting put the inode back on the LRU list and
mark it REFERENCED.

It seems like if NFS were to extend its implementation of drop_inode()
to check if we still have a delegation, then not to evict this inode,
it would prevent the race from happening. I would like to know if
there is/was a reason not implement drop_inode(). One reason is that
if we have too many files with delegations opened, then we'll have
resources problem. In that case, we can complicate our delegation
returning policies (return it more aggressively under a heavy load).

Any thoughts about this?
