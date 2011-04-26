Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-1.desy.de ([131.169.56.84]:49557 "EHLO
	smtp-out-1.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755997Ab1DZOFZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Apr 2011 10:05:25 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-out-1.desy.de (DESY_OUT_1) with ESMTP id DA70417EA
	for <linux-nfs@vger.kernel.org>; Tue, 26 Apr 2011 16:05:23 +0200 (MEST)
Received: from adserv71.win.desy.de (adserv71.win.desy.de [131.169.97.57])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id D35D813ED0
	for <linux-nfs@vger.kernel.org>; Tue, 26 Apr 2011 16:05:23 +0200 (MEST)
Message-ID: <4DB6D0CC.4050601@desy.de>
Date: Tue, 26 Apr 2011 16:03:56 +0200
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: NFS list <linux-nfs@vger.kernel.org>, Steve Dickson <SteveD@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: pNFS read/write behavior change in 2.6.39
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


I run 2.6.39-0.rc4.git2.0 build for fedora-16 build by redhat.
Probably Steve and Bruce can comment on the patch set.

My observation is that state id provided by client on read to
DS dit not contain correct stateid:

struct stateid4 {
         uint32_t        seqid;
         opaque          other[12];
};

The seqid equals to zero when client send it to DS which is not the
value returned on OPEN.

The problem is not observed with

ae7441fa120ff35b40b4dab167645907a9da1dab

from Bennys tree  as well as with frdora 15 builds from Steve.
With
Regards,
    Tigran.
