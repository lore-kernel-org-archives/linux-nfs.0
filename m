From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/6] Refactor client_check()
Date: Tue, 23 Mar 2010 12:52:40 -0400
Message-ID: <20100323165122.4368.43659.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:48378 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752524Ab0CWQwo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Mar 2010 12:52:44 -0400
Received: by qyk9 with SMTP id 9so951500qyk.1
        for <linux-nfs@vger.kernel.org>; Tue, 23 Mar 2010 09:52:43 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

These patches refactor client_check() so that IPv6 support can be
added down the road.  They should introduce no change in behavior.

---

Chuck Lever (6):
      libexport.a: replace xlog(L_FATAL) in client_check()
      libexport.a: Refactor wildcard checking in client_check()
      libexport.a: Refactor netgroup checking in client_check()
      libexport.a: Remove unused function client_checkaddr()
      libexport.a: Factor SUBNETWORK checking out of check_client()
      libexport.a: Factor FQDN checking out of check_client()


 support/export/client.c |  204 ++++++++++++++++++++++++++++++-----------------
 1 files changed, 130 insertions(+), 74 deletions(-)

-- 
Chuck Lever
