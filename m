Return-Path: linux-nfs-owner@vger.kernel.org
Received: from prod-mail-xrelay07.akamai.com ([72.246.2.115]:28419 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751254AbaIRTvs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Sep 2014 15:51:48 -0400
To: trond.myklebust@primarydata.com, bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Message-Id: <cover.1411068259.git.jbaron@akamai.com>
From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH 0/2] rpc: resolve softlockup in presence of iptables drop rule
Date: Thu, 18 Sep 2014 19:51:47 +0000 (GMT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

We've found a softlockup on the nfsv3 client (udp), while testing an iptables
rule, which simply drops traffic destined for the nfs server. The softlockup
occurs because xs_sendpages() returns a positive result (resulting in an
-EAGAIN), masking out the -EPERM that the lower level ip code returns.

The first patch restructures xs_sendpages() such that it can return a 'sent'
value in addition to an error value. It no longer over-loads the return value
as both a 'sent' and 'error' value. In this way the 'higher' level code can
make more informed decisions. This patch is intended to be a no-op.

The second patch makes use of the new return value to propagate the -EPERM
up instead of the -EAGAIN.

Thanks,

-Jason


Jason Baron (2):
  rpc: return sent and err from xs_sendpages()
  rpc: Add -EPERM processing for xs_udp_send_request()

 net/sunrpc/clnt.c     |  2 ++
 net/sunrpc/xprtsock.c | 86 ++++++++++++++++++++++++++++-----------------------
 2 files changed, 49 insertions(+), 39 deletions(-)

-- 
1.8.2.rc2

