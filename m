From: Ivan Yosifov <iyosifov@gmail.com>
Subject: Question: NFS behaviour in case of concurrent local and remote
 access
Date: Mon, 09 Nov 2009 14:42:49 +0200
Message-ID: <1257770569.7276.31.camel@home.yosifov.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:47943 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755546AbZKIMmr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Nov 2009 07:42:47 -0500
Received: by mail-bw0-f227.google.com with SMTP id 27so3397119bwz.21
        for <linux-nfs@vger.kernel.org>; Mon, 09 Nov 2009 04:42:52 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi everyone,

I'm new to NFS and am trying to understand how to use it safely and
correctly.

The situation I'm considering is following. There's a server with an
( ext4 if it matters ) local volume that's exported through NFSv4. There
are expected to be both remote ( ie. over the NFS ) read/write clients
and local ones that write to the volume directly ( ie. not thorough the
NFS ).

Assuming well-behaved clients, ie. no interleaved open()...close() on
the same file, how will NFS handle this ? Will close-to-open consistency
continue to work, will it interfere with delegations ?

Pointers or thoughts greatly appreciated.

Thanks,
Ivan Yosifov

