From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/4] RFC: How to register IPv6 addresses with local rpcbind
Date: Tue, 08 Jan 2008 11:30:55 -0500
Message-ID: <20080108162751.21088.40126.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:31605 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754204AbYAHQa5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jan 2008 11:30:57 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m08GUuSF010117
	for <linux-nfs@vger.kernel.org>; Tue, 8 Jan 2008 08:30:56 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m08GUtl1021107
	for <linux-nfs@vger.kernel.org>; Tue, 8 Jan 2008 11:30:55 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As I wend my way towards IPv6 support in the kernel NLM, I've hacked together
some new functionality in the RPC server to allow services to register IPv6
listeners with the local user-space rpcbind.  These patches provide an API to
use rpcbind v3 SET/UNSET calls to register IPv6 capabilities.

Comments?  Thoughts?

-- 
corporate:    <chuck dot lever at oracle dot com>
