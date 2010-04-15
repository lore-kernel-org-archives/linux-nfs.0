Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f189.google.com ([209.85.221.189]:33051 "EHLO
	mail-qy0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754444Ab0DOPZJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Apr 2010 11:25:09 -0400
Received: by qyk27 with SMTP id 27so1787265qyk.23
        for <linux-nfs@vger.kernel.org>; Thu, 15 Apr 2010 08:25:08 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] Handle address parsing errors in export_find()
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 15 Apr 2010 11:25:00 -0400
Message-ID: <20100415152401.4716.83632.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Steve-

Two more short subjects in the mountd IPv6 series.

---

Chuck Lever (2):
      libexport.a: export_find() should handle address parsing errors
      libexport.a: Add export_free()


 support/export/export.c |   31 +++++++++++++++++++++----------
 1 files changed, 21 insertions(+), 10 deletions(-)

-- 
Chuck Lever
