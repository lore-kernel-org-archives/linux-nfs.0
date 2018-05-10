Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-fw-33001.amazon.com ([207.171.190.10]:42564 "EHLO
        smtp-fw-33001.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756233AbeEJGNA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 May 2018 02:13:00 -0400
From: Vallish Vaidyeshwara <vallish@amazon.com>
To: <trond.myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <jlayton@kernel.org>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>
CC: <jsstraus@amazon.com>
Subject: [PATCH 0/2] SUNRPC: Clean up port reuse behavior on reconnects
Date: Thu, 10 May 2018 06:12:52 +0000
Message-ID: <1525932774-98736-1-git-send-email-vallish@amazon.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We have seen examples of NFSv4 client reconnections failing due to
client source port reuse combined with stateful TCP state tracking in
middleboxes.

Commit 0f7a622ca616 ("rpc: xs_bind - do not bind when requesting a
random ephemeral port"), commit 4dda9c8a5e34 ("SUNRPC: Set SO_REUSEPORT
socket option for TCP connections"), and commit 1f4c17a03ba7 ("SUNRPC:
Handle EADDRNOTAVAIL on connection failures") had unintended side effects
of making port reuse dependent on whether that client uses reserved or
non-reserved source ports.

This series fixes the observed NFSv4 client reconnect failures by
choosing a new source port regardless of which port range is in use
for RST or FIN terminating the prior connection. This series does
not restore the original always-reuse behavior that existed prior to
commits mentioned above.

Patch 1:
--------
SUNRPC: Need to reuse non-reserved port for reconnect

This patch restores the original behavior of port reuse in all
scenarios.

Patch 2:
--------
SUNRPC: Reconnect with new port on server initiated connection
    termination

Client uses a new port only in cases where server has terminated
the connection explicitly using RST or FIN.

Proposed outcome with this patch series:
----------------------------------------
------------------------------------------------------------------
| Port type | Connection termination | Current    | With this    |
|           |         type           | behavior   | patch series |
------------------------------------------------------------------
|  Reserved | Network partition-DROP | Reuse port | Reuse port   |
------------------------------------------------------------------
|  Reserved | FIN from server        | Reuse port | New port     |
------------------------------------------------------------------
|  Reserved | RST from server        | Reuse port | New port     |
------------------------------------------------------------------
|  Non-Resv | Network partition-DROP | New port   | Reuse port   |
------------------------------------------------------------------
|  Non-Resv | FIN from server        | New port   | New port     |
------------------------------------------------------------------
|  Non-Resv | RST from server        | New port   | New port     |
------------------------------------------------------------------

 net/sunrpc/xprtsock.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

-- 
2.7.3.AMZN

