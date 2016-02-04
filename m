Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:34082 "EHLO
	mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533AbcBDRkH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Feb 2016 12:40:07 -0500
Received: by mail-lf0-f43.google.com with SMTP id j78so41256286lfb.1
        for <linux-nfs@vger.kernel.org>; Thu, 04 Feb 2016 09:40:06 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 4 Feb 2016 18:40:06 +0100
Message-ID: <CAKbOo_KVR8F6Keqyzv_=Mv9CRvs_R0p5L3twRf8mT0s4ThsdBQ@mail.gmail.com>
Subject: NFS4 recovery capabilities in failover clusters
From: Matthias Eble <psychotrahe@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I've been trying to find out how I can build an HA (active/passive)
NFS4 failover
cluster with smooth failure recovery. After a takeover, or when
clients return from isolation,
D-state processes and stale handles, etc should be prevented.
What I found were some linux-nfs wiki pages [1] about problems with recovery in
the linux implementation, and some hints about nfs 4.1's transparent
state migration.

What I couldn't find out is, how to actually use TSM, what it can do,
and what it can't.

So I have two questions:
* Have the issues mentioned in [1] been fixed and is the linux NFS4
client/server
  implementation currently able to provide solid recovery in a failover cluster?
  Just mount FS on other node + virtual IP?
* If so, do you have any hints, keywords, links etc with up-to-date information,
  what needs to be done to make such a cluster/recovery as resilient
as possible?
  Is just syncing v4recovery enough?

I've tried to get some definitive information on the net, the results
were either dated
or incomplete. And I guess the RFC does not necessarily apply to the
linux implementation, right?

Any help is appreciated.
Thanks for your time.
Matthias

[1] http://linux-nfs.org/wiki/index.php/NFS_Recovery_and_Client_Migration
