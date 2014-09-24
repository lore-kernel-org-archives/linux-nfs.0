Return-Path: linux-nfs-owner@vger.kernel.org
Received: from prod-mail-xrelay07.akamai.com ([72.246.2.115]:35227 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753449AbaIXSH5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Sep 2014 14:07:57 -0400
To: trond.myklebust@primarydata.com
Cc: bfields@fieldses.org, Anna.Schumaker@netapp.com, linux-nfs@vger.kernel.org
Message-Id: <cover.1411580799.git.jbaron@akamai.com>
From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH v2 0/2] rpc: resolve softlockup in presence of iptables drop rule
Date: Wed, 24 Sep 2014 18:07:56 +0000 (GMT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v2:
-return -EIO after major timeout on a soft mount, continue to retry if its a
hard mount
-fixup changelogs

Hi,

We've found a softlockup on the nfsv3 client (udp), while testing an iptables
rule, which simply drops traffic destined for the nfs server. The softlockup
occurs because xs_sendpages() returns a positive result (resulting in an
-EAGAIN), masking out the -EPERM that the lower level ip code returns.

The first patch restructures xs_sendpages() such that it can return a 'sent'
value in addition to an error value. It no longer over-loads the return value
as both a 'sent' and 'error' value. In this way the 'higher' level code can
make more informed decisions.

The second patch makes use of the new return value to propagate an -EIO
up instead of the -EAGAIN and avoids the cpu spinning.

Thanks,

-Jason


Jason Baron (2):
  rpc: return sent and err from xs_sendpages()
  rpc: Add -EPERM processing for xs_udp_send_request()

 net/sunrpc/clnt.c     |  2 ++
 net/sunrpc/xprtsock.c | 87 ++++++++++++++++++++++++++++-----------------------
 2 files changed, 50 insertions(+), 39 deletions(-)

-- 
1.8.2.rc2

