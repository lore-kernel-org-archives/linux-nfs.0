Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:37283 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751106AbdGaU2p (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Jul 2017 16:28:45 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: lockd: server not responding
Date: Mon, 31 Jul 2017 16:28:39 -0400
Message-Id: <7B576AFA-7EF1-459E-827E-8793F50DB50C@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Jeff Layton <jlayton@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff-

Observed with v4.13-rc[23] during NFSv3 connectation testing.
The lock test stalls for a minute or two during test #7.

If you haven't already seen this, I can dig deeper.

Jul 31 16:11:08 klimt rpc.mountd[1640]: authenticated mount request from 192.168.2.2:864 for /export/tmp (/export/tmp)
Jul 31 16:11:28 klimt rpc.mountd[1640]: authenticated unmount request from 192.168.2.2:740 for /export/tmp (/export/tmp)
Jul 31 16:11:28 klimt rpc.mountd[1640]: authenticated mount request from 192.168.2.2:844 for /export/tmp (/export/tmp)
Jul 31 16:12:35 klimt kernel: lockd: server manet.1015granger.net not responding, timed out
Jul 31 16:12:49 klimt rpc.mountd[1640]: authenticated unmount request from 192.168.2.2:989 for /export/tmp (/export/tmp)
Jul 31 16:12:49 klimt rpc.mountd[1640]: authenticated mount request from 192.168.2.2:844 for /export/tmp (/export/tmp)
Jul 31 16:13:10 klimt rpc.mountd[1640]: authenticated unmount request from 192.168.2.2:813 for /export/tmp (/export/tmp)
Jul 31 16:13:10 klimt rpc.mountd[1640]: authenticated mount request from 192.168.2.2:860 for /export/tmp (/export/tmp)
Jul 31 16:14:25 klimt kernel: lockd: server manet.1015granger.net not responding, timed out
Jul 31 16:14:30 klimt rpc.mountd[1640]: authenticated unmount request from 192.168.2.2:636 for /export/tmp (/export/tmp)
Jul 31 16:14:30 klimt rpc.mountd[1640]: authenticated mount request from 192.168.2.2:960 for /export/tmp (/export/tmp)
Jul 31 16:14:51 klimt rpc.mountd[1640]: authenticated unmount request from 192.168.2.2:884 for /export/tmp (/export/tmp)
Jul 31 16:14:51 klimt rpc.mountd[1640]: authenticated mount request from 192.168.2.2:822 for /export/tmp (/export/tmp)
Jul 31 16:17:02 klimt rpc.mountd[1640]: authenticated unmount request from 192.168.2.2:778 for /export/tmp (/export/tmp)


--
Chuck Lever



