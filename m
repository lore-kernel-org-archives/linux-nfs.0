Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:44635
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752123Ab1DTUuA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Apr 2011 16:50:00 -0400
Date: Wed, 20 Apr 2011 22:49:51 +0200
From: Michael Guntsche <mike@it-loops.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [BUG] supported_krb5_enctypes not available if GSS support compiled
 as a module
Message-ID: <20110420224241@it-loops.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello Bruce,

Commit 0a5e5f122c nfsd: fix compile error fixed a compile error by
putting the code between an #ifdef CONFIG_SUNRPC_GSS.

In my case this is compiled as a module so CONFIG_SUNRPC_GSS_MODULE is
defined but not CONFIG_SUNRPC_GSS. I do not know if this was on purpose
but as it is now "supported_krb5_enctypes" is only available if GSS
support is compiled in the kernel.

Kind regards,
Michael
