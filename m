Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.82]:45402 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751892Ab1LVPXV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Dec 2011 10:23:21 -0500
Date: Thu, 22 Dec 2011 10:23:13 -0500
From: Jim Rees <rees@umich.edu>
To: Jeff Layton <jlayton@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, bfields@fieldses.org,
        steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 4/5] nfsd: add a header describing upcall to nfsdcld
Message-ID: <20111222152313.GB2500@umich.edu>
References: <1324499696-10318-1-git-send-email-jlayton@redhat.com>
 <1324499696-10318-5-git-send-email-jlayton@redhat.com>
 <46975244-4C42-4DC9-832B-E3597B8013FD@oracle.com>
 <20111221163312.3405c1f3@tlielax.poochiereds.net>
 <121533D1-9C5C-45EA-AF8F-90AA4167B066@oracle.com>
 <20111222080706.7a064430@tlielax.poochiereds.net>
 <20111222152051.GA2500@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111222152051.GA2500@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jim Rees wrote:

  Having recently added a new rpc_pipe upcall for idmapd,...

That should read "blkmapd" of course.
