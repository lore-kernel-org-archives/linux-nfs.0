From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] lockd: fix race in nlm_release()
Date: Wed, 20 Feb 2008 18:49:29 -0500
Message-ID: <20080220234929.GO30160@fieldses.org>
References: <20080220191153.GG30160@fieldses.org> <1203535466.15034.5.camel@heimdal.trondhjem.org> <20080220192759.GI30160@fieldses.org> <1203536918.15034.11.camel@heimdal.trondhjem.org> <022C8A98-7487-475C-AD9C-89DDB2B1252C@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:44435 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757257AbYBTXti (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Feb 2008 18:49:38 -0500
In-Reply-To: <022C8A98-7487-475C-AD9C-89DDB2B1252C@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 20, 2008 at 05:10:24PM -0500, Chuck Lever wrote:
> On Feb 20, 2008, at 2:48 PM, Trond Myklebust wrote:
>> Just the usual plea to replace the host->h_server flag with 2 separate
>> lists: one list of client nlm_hosts, and one list of server
>> nlm_hosts :-)
>
> I have no objection to that, but my NLM IPv6 patches will be  
> significantly affected by such a change right at this point.  Can we  
> hold off until the IPv6 work is integrated, or make this change part of 
> the IPv6 work itself?

Just speak up before I try to merge it, and we'll work something out....

--b.
