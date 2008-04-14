From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/24] RPC server support rpcbind v4 plus additional clean ups
Date: Mon, 14 Apr 2008 12:26:38 -0400
Message-ID: <20080414162108.12741.73233.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]:40021 "EHLO
	flpi195.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755113AbYDNRBC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2008 13:01:02 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce, Trond -

This patch series provides some minor clean ups, and finishes with an
implementation of support for rpcbind version 4 registration.  Version 4
support can be entirely disabled in favor of legacy behavior with a kernel
build option, and the default is to use rpcbind version 2 when registering
kernel RPC services.

There are 24 patches in this series, but only a few are more than trivial and
hopefully fewer yet are controversial.  I've tried to split these so that
server side and client side changes are in separate patches.

It would be helpful for me if they could be considered for 2.6.26.

-- 
corporate:    <chuck dot lever at oracle dot com>
