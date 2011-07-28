Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([83.163.148.79]:46137 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754757Ab1G1Soj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jul 2011 14:44:39 -0400
From: Frank van Maarseveen <frankvm@frankvm.com>
To: linux-nfs@vger.kernel.org
Subject: [NLM] support for a per-mount grace period.
Date: Thu, 28 Jul 2011 20:44:18 +0200
Message-Id: <1311878660-24482-1-git-send-email-frankvm@frankvm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The following two patches implement support for a per-mount NLM
grace period. The first patch is a minor cleanup which pushes
down locks_in_grace() calls into functions shared by NFS[234]. Two
locks_in_grace() tests have been reordered to avoid duplicate calls at
run-time (assuming gcc is smart enough). nlmsvc_grace_period is now a
function instead of an unused variable.

The second patch is the actual implementation. It is currently in use for
a number of NFSv3 virtual servers on one physical machine running 2.6.39.3
where the virtualization is based on using different IPv4 addresses.

The patches have been created using a recent 3.0 tree.
-- 
Frank
