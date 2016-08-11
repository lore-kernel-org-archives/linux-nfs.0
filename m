Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:33516 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490AbcHKRKr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2016 13:10:47 -0400
Received: by mail-qk0-f178.google.com with SMTP id t7so1995600qkh.0
        for <linux-nfs@vger.kernel.org>; Thu, 11 Aug 2016 10:10:47 -0700 (PDT)
Message-ID: <1470935443.30238.41.camel@redhat.com>
Subject: Re: CB_LAYOUTRECALL "deadlock" with in-kernel flexfiles server and
 XFS
From: Jeff Layton <jlayton@redhat.com>
To: hch <hch@lst.de>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        Thomas Haynes <loghyr@primarydata.com>,
        Fields Bruce James <bfields@fieldses.org>
Date: Thu, 11 Aug 2016 13:10:43 -0400
In-Reply-To: <20160811165902.GA25717@lst.de>
References: <1470929036.30238.14.camel@redhat.com>
	 <CA55873C-4CF9-42F8-A35E-07C9CB685800@primarydata.com>
	 <1470931603.30238.25.camel@redhat.com>
	 <66A7F612-4704-43CB-AE93-6C1A8A52D6DA@primarydata.com>
	 <20160811162521.GA24116@lst.de> <1470933227.30238.35.camel@redhat.com>
	 <20160811165902.GA25717@lst.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-08-11 at 18:59 +0200, hch wrote:
> On Thu, Aug 11, 2016 at 12:33:47PM -0400, Jeff Layton wrote:
> > 
> > On Thu, 2016-08-11 at 18:25 +0200, hch wrote:
> > > 
> > > Yeah, for file-like layouts there should be a flag in
> > > struct nfsd4_layout_ops to disable recalls.
> > 
> > I don't think disabling recalls would be enough, would it? XFS
> > still
> > wants to break_layout and won't proceed until the layout list is
> > empty,
> > AFAICT. We need some way to indicate to the lower filesystem not to
> > call break_layout in this case.
> 
> XFS only cares about block-like layours where the client has direct
> access to the file blocks.  I'd need to look how to propagate the
> flag into break_layout, but in principle we don't need to do any
> recalls on truncate every for file and flexfile layouts.
> 

Hmm...if we aren't ever going to recall files and flexfiles layouts,
then do we even need to set a FL_LAYOUT lease for them at all?

I think I'll try hacking something up that takes that approach and see
if that might be a reasonable fix.

-- 
Jeff Layton <jlayton@redhat.com>
