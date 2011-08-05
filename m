Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:39483 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752958Ab1HEBji (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Aug 2011 21:39:38 -0400
Date: Thu, 4 Aug 2011 21:39:36 -0400
From: Jim Rees <rees@umich.edu>
To: Max Matveev <makc@redhat.com>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: [PATCH] Update nfs(5) manpage - timeo for NFS/TCP
Message-ID: <20110805013936.GB15643@merit.edu>
References: <20026.13331.411712.805796@regina.usersys.redhat.com>
 <20110804062858.EAD96813270B@regina.usersys.redhat.com>
 <20110804120401.GB9984@merit.edu>
 <20027.16401.281058.897798@regina.usersys.redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20027.16401.281058.897798@regina.usersys.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Max Matveev wrote:

  	The NFS client performs linear backoff: after each
  	retransmission the timeout is increased by timeo up to the
  	maximum of 600 seconds.

Good point about keeping this together.  Probably should be a semicolon, but
if you go with a colon, capitalize "after".
