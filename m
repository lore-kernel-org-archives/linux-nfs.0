Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:38990 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753988AbbEKNWf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 May 2015 09:22:35 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH] SUNRPC: Clean up bc_send()
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20150511071634.GA31452@infradead.org>
Date: Mon, 11 May 2015 09:22:24 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <BB2F0712-DE3F-4153-9159-6F8EDC0D0469@oracle.com>
References: <20150507232028.2092.78506.stgit@manet.1015granger.net> <20150511071634.GA31452@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 11, 2015, at 3:16 AM, Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, May 07, 2015 at 07:20:28PM -0400, Chuck Lever wrote:
>> Clean up: Merge bc_svc.c into backchannel_rqst.c, and adopt a more
>> consistent naming scheme for bc_send().
> 
> Seems like a bit of an odd choise as none of the callchain bc_send
> is in really touches backchannel_rqst.c.
> 
> How about just killing bc_send() and open coding it in bc_svc_process?

OK, that sounds reasonable.

> And while we're at it - bc_svc_process seems totally generic RPC
> code that might want to be moved to net/sunrpc and converted to
> a workqueue.

That is underway.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



