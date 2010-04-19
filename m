Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:50362 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752004Ab0DSUVI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Apr 2010 16:21:08 -0400
Received: by qyk9 with SMTP id 9so6081157qyk.1
        for <linux-nfs@vger.kernel.org>; Mon, 19 Apr 2010 13:21:07 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/4] Four more pre-requisites for mountd IPv6 support
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 19 Apr 2010 16:20:51 -0400
Message-ID: <20100419201855.3567.9644.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Steve-

These patches clean up some memory allocation nits in libexport.a.
They pave the way for parsing IPv6 addresses and netmasks in
client_init().

---

Chuck Lever (4):
      libexport.a: Allow malloc(3) failures in client_lookup() and friends
      libexport.a: Allow m_hostname allocation to fail instead of exit
      libexport.a: Allow client_init() to fail instead of exit
      libexport.a: Add client_free()


 support/export/client.c |   55 +++++++++++++++++++++++++++++++----------------
 1 files changed, 36 insertions(+), 19 deletions(-)

-- 
Chuck Lever
