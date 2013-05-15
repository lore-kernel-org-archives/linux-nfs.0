Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45576 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759830Ab3EORjR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 May 2013 13:39:17 -0400
Date: Wed, 15 May 2013 13:39:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] NFS: Fall back to AUTH_SYS for SETCLIENTID (take 2)
Message-ID: <20130515173916.GM16811@fieldses.org>
References: <20130513161515.1942.845.stgit@seurat.1015granger.net>
 <20130513162528.1942.64673.stgit@seurat.1015granger.net>
 <20130515160424.GK16811@fieldses.org>
 <961AC5FB-617E-48FB-A35F-5E1A25213292@oracle.com>
 <20130515171601.GL16811@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130515171601.GL16811@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

By the way, have you looked at SP4_MACH_CRED at all yet?  It's a selfish
question (I could use something to test against), but I think it's also
what you want if you want krb5i-protected 4.1 state.

--b.
