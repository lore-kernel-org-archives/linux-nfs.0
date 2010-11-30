Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:47667 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752215Ab0K3DPM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Nov 2010 22:15:12 -0500
Date: Mon, 29 Nov 2010 22:15:07 -0500
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/4] Allow the admin to turn off NFSv4 uid/gid mapping
Message-ID: <20101130031507.GA2640@merit.edu>
References: <1291085863-3234-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1291085863-3234-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust wrote:

  The following patches allow the admin to turn off NFSv4 uid/gid mapping
  if mounting using AUTH_SYS security.
  
  The new behaviour is enabled using a module parameter,
  nfs4_disable_idmapping.

Would this be more useful as a per-mount option rather than a global?
