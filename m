Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dragon.async.com.br ([208.70.149.241]:34572 "EHLO
	dragon.async.com.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755429AbcCUOpH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Mar 2016 10:45:07 -0400
Received: from anthem.async.com.br (189-19-234-109.dsl.telesp.net.br [189.19.234.109])
	by dragon.async.com.br (Postfix) with ESMTPS id 2299B4540F3
	for <linux-nfs@vger.kernel.org>; Mon, 21 Mar 2016 09:39:20 -0500 (CDT)
Received: from anthem.async.com.br (kiko@localhost [127.0.0.1])
	by anthem.async.com.br (8.14.4/8.14.4/Debian-2ubuntu2.1) with ESMTP id u2LEdFOE006892
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Mon, 21 Mar 2016 11:39:15 -0300
Received: (from kiko@localhost)
	by anthem.async.com.br (8.14.4/8.14.4/Submit) id u2LEdElW006891
	for linux-nfs@vger.kernel.org; Mon, 21 Mar 2016 11:39:14 -0300
Date: Mon, 21 Mar 2016 11:39:14 -0300
From: Christian Robottom Reis <kiko@acm.org>
To: NFS List <linux-nfs@vger.kernel.org>
Subject: Finding and breaking client locks
Message-ID: <20160321143914.GA6397@anthem.async.com.br>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello there,

    I run a diskless network where every user NFS mounts pretty much
everything including /home and /var/mail. It's often the case that a
misbehaved client will leave a locked file stuck on the server -- today
it is a file in a user's mail/ directory.

Is there a way to query what files are being held locked by clients? I'm
sure the kernel knows, as it is able to enforce the lock, but it isn't
obvious how to extract that information -- lsof is documented to and
indeed does not return any information pertaining NFS client locks, and
I'm not clear whether /proc/locks (on the server side obviously) does or
not.

A related question is whether it is possible to break a client lock
without rebooting the server (or restarting the NFS services).

Does anyone have any insight to share? Thanks,
-- 
Christian Robottom Reis | [+55 16] 3376 0125   | http://async.com.br/~kiko
                        | [+55 16] 991 126 430 | http://launchpad.net/~kiko
