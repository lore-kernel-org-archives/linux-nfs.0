Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:34036 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010Ab3KOXRA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Nov 2013 18:17:00 -0500
Received: by mail-pb0-f46.google.com with SMTP id un15so4232129pbc.19
        for <linux-nfs@vger.kernel.org>; Fri, 15 Nov 2013 15:16:59 -0800 (PST)
Message-ID: <1384557410.3222.2.camel@leira.trondhjem.org>
Subject: Re: [PATCH] NFS: Fix kbuild errors due to missing symbols
From: Trond Myklebust <trondmy@gmail.com>
To: Anna Schumaker <bjschuma@netapp.com>
Cc: linux-nfs@vger.kernel.org
Date: Fri, 15 Nov 2013 18:16:50 -0500
In-Reply-To: <1384554636-25330-1-git-send-email-bjschuma@netapp.com>
References: <1384554636-25330-1-git-send-email-bjschuma@netapp.com>
Content-Type: text/plain; charset="UTF-7"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2013-11-15 at 17:30 -0500, Anna Schumaker wrote:
+AD4 My recent patch 644aa303: +ACI-NFS: Enabling v4.2 should not recompile nfsd
+AD4 and lockd+ACI caused build errors when CONFIG+AF8-NFS+AF8-USE+AF8-LEGACY+AF8-DNS+AD0-y and when
+AD4 CONFIG+AF8-NFS+AF8-V4+AD0-n.  This patch fixes those errors.
+AD4 

Wait... 

        config NFS+AF8-USE+AF8-LEGACY+AF8-DNS
                bool +ACI-Use the legacy NFS DNS resolver+ACI
                depends on NFS+AF8-V4
                help
                  The kernel now provides a method for translating a host name into an
                  IP address.  Select Y here if you would rather use your own DNS
                  resolver script.
        
                  If unsure, say N
        
        config NFS+AF8-USE+AF8-KERNEL+AF8-DNS
                bool
                depends on NFS+AF8-V4 +ACYAJg +ACE-NFS+AF8-USE+AF8-LEGACY+AF8-DNS
                select DNS+AF8-RESOLVER
                default y

How can that result in NFS+AF8-V4+AD0-n +ACYAJg NFS+AF8-USE+AF8-LEGACY+AF8-DNS+AD0-y?

