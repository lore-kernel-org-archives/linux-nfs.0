From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NFS: don't try to decode GETATTR if DELEGRETURN
 returned error
Date: Sun, 21 Mar 2010 12:15:33 -0400
Message-ID: <1269188133.3215.1.camel@localhost.localdomain>
References: <1269170258-31596-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44061 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752034Ab0CUQQn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Mar 2010 12:16:43 -0400
In-Reply-To: <1269170258-31596-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2010-03-21 at 07:17 -0400, Jeff Layton wrote: 
> The reply parsing code attempts to decode the GETATTR response even if
> the DELEGRETURN portion of the compound returned an error. The GETATTR
> response won't actually exist if that's the case and we're asking the
> parser to read past the end of the response.
> 
> This bug is fairly benign. The parser catches this without reading past
> the end of the response and decode_getfattr returns -EIO. Earlier
> kernels however had decode_op_hdr using the READ_BUF macro, and this
> bug would make this printk pop any time the client got an error from
> a delegreturn:
> 
> kernel: decode_op_hdr: reply buffer overflowed in line XXXX
> 
> More recent kernels seem to have replaced this printk with a dprintk.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

Applied. Thanks!

Trond
