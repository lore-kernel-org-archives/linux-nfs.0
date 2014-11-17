Return-Path: linux-nfs-owner@vger.kernel.org
Received: from gproxy6-pub.mail.unifiedlayer.com ([67.222.39.168]:41696 "HELO
	gproxy6-pub.mail.unifiedlayer.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751647AbaKQSqO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2014 13:46:14 -0500
Received: from [24.130.49.43] (port=49400 helo=monster.martins.cc)
	by box503.bluehost.com with esmtpsa (TLSv1.2:DHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.82)
	(envelope-from <linux@martins.cc>)
	id 1XqOcW-0004ln-Gy
	for linux-nfs@vger.kernel.org; Mon, 17 Nov 2014 08:53:40 -0700
Received: from monster.martins.cc (monster.martins.cc [127.0.0.1])
	by monster.martins.cc (Postfix) with ESMTP id 53EFC622CC
	for <linux-nfs@vger.kernel.org>; Mon, 17 Nov 2014 07:53:36 -0800 (PST)
From: Henrique Martins <linux@martins.cc>
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] nfsd/exportfs: allow empty exports file
In-reply-to: <5469F395.9080701@RedHat.com>
References: <17903.1415988313@monster.martins.cc> <5469F395.9080701@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Mon, 17 Nov 2014 07:53:36 -0800
Message-ID: <29411.1416239616@monster.martins.cc>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

steved> The presidence has been set that having an empty
steved> export file is not a problem. So I would rather
steved> change that xlog to be a L_WARNING and only log it
steved> when the verbose is set.

The situation, PRECEDENCE, when I got involved was:
  no entries in exports:
    nothing logged, nfsd started
  all good entries in exports
    nothing logged, nfsd started
  mixture of bad and good entries in exports
    bad entries logged, error logged, nfsd aborted
  all bad entries in exports
    bad entries logged, error logged, nfsd aborted

My first patch overlooked that first condition, and made the
situation like below, changed from PRECEDENCE uppercased:
  no entries in exports:
    EMPTY LOGGED, NFSD ABORTED
  all good entries in exports
    nothing logged, nfsd started
  mixture of bad and good entries in exports
    bad entries logged, NFSD STARTED
  all bad entries in exports
    bad entries logged, error logged, nfsd aborted

Current patch makes it, changes from PRECEDENCE uppercased:
  no entries in exports:
    nothing logged, nfsd started
  all good entries in exports
    nothing logged, nfsd started
  mixture of bad and good entries in exports
    bad entries logged, NFSD STARTED
  all bad entries in exports
    bad entries logged, error logged, nfsd aborted

Your patch makes it, changes from PRECEDENCE uppercased:
  no entries in exports:
    WARNING LOGGED, nfsd started
  all good entries in exports
    nothing logged, nfsd started
  mixture of bad and good entries in exports
    bad entries logged, NFSD STARTED
  all bad entries in exports
    bad entries logged, NFSD STARTED

Your pick,

-- Henrique
