Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:22293 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756504Ab3EQR4X convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 May 2013 13:56:23 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/3] SUNRPC: Convert auth_gss pipe detection to work in
 namespaces
Date: Fri, 17 May 2013 17:55:28 +0000
Message-ID: <1368813327.9073.5.camel@leira.trondhjem.org>
References: <1368647441-24815-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1368647441-24815-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1368647441-24815-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1368647441-24815-4-git-send-email-Trond.Myklebust@netapp.com>
	 <20130516202142.GB3216@fieldses.org>
In-Reply-To: <20130516202142.GB3216@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-05-16 at 16:21 -0400, J. Bruce Fields wrote:
> On Wed, May 15, 2013 at 12:50:41PM -0700, Trond Myklebust wrote:
> > This seems to have been overlooked when we did the namespace
> > conversion. If a container is running a legacy version of rpc.gssd
> > then it will be disrupted if the global 'pipe_version' is set by a
> > container running the new version of rpc.gssd.
> 
> Might be worth deprecating the "legacy" version--add a warning in for
> any users and then remove it if we don't see any evidence anyone's hit
> it recently.

Possibly, however given that we're still seeing distros using the binary
mount interface that was replaced 6 years ago...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
