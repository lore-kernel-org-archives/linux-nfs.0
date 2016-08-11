Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:34814 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932493AbcHKQdz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2016 12:33:55 -0400
Received: by mail-qk0-f178.google.com with SMTP id p186so829846qkd.1
        for <linux-nfs@vger.kernel.org>; Thu, 11 Aug 2016 09:33:55 -0700 (PDT)
Message-ID: <1470933227.30238.35.camel@redhat.com>
Subject: Re: CB_LAYOUTRECALL "deadlock" with in-kernel flexfiles server and
 XFS
From: Jeff Layton <jlayton@redhat.com>
To: hch <hch@lst.de>, Trond Myklebust <trondmy@primarydata.com>
Cc: List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        Thomas Haynes <loghyr@primarydata.com>,
        Fields Bruce James <bfields@fieldses.org>
Date: Thu, 11 Aug 2016 12:33:47 -0400
In-Reply-To: <20160811162521.GA24116@lst.de>
References: <1470929036.30238.14.camel@redhat.com>
	 <CA55873C-4CF9-42F8-A35E-07C9CB685800@primarydata.com>
	 <1470931603.30238.25.camel@redhat.com>
	 <66A7F612-4704-43CB-AE93-6C1A8A52D6DA@primarydata.com>
	 <20160811162521.GA24116@lst.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-08-11 at 18:25 +0200, hch wrote:
> Yeah, for file-like layouts there should be a flag in
> struct nfsd4_layout_ops to disable recalls.

I don't think disabling recalls would be enough, would it? XFS still
wants to break_layout and won't proceed until the layout list is empty,
AFAICT. We need some way to indicate to the lower filesystem not to
call break_layout in this case.

-- 
Jeff Layton <jlayton@redhat.com>
