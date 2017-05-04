Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:49540 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750710AbdEDUm6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 May 2017 16:42:58 -0400
Date: Thu, 4 May 2017 16:42:58 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [RFC PATCH 2/5] NFS: Add a mount option to specify number of TCP
 connections to use
Message-ID: <20170504204258.GE7023@fieldses.org>
References: <20170428172535.7945-1-trond.myklebust@primarydata.com>
 <20170428172535.7945-2-trond.myklebust@primarydata.com>
 <20170428172535.7945-3-trond.myklebust@primarydata.com>
 <EC0AD66D-D8B5-4912-A2DC-5B9167D2A01A@oracle.com>
 <F87DB5F9-829B-43BD-B823-243A6E1F0A41@oracle.com>
 <20170504173638.GA7023@fieldses.org>
 <F868F692-7CB7-4388-94E7-7D4052CE89F1@oracle.com>
 <20170504174549.GB7023@fieldses.org>
 <1493930404.6900.2.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1493930404.6900.2.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 04, 2017 at 08:40:07PM +0000, Trond Myklebust wrote:
> See https://tools.ietf.org/html/rfc5661#section-2.10.3.1
> 
> So, we probably should send the BIND_CONN_TO_SESSION after creating the
> session, but since that involves figuring out whether or not state
> protection was successfully negotiated, and since we have to support
> handling NFS4ERR_CONN_NOT_BOUND_TO_SESSION anyway, I'm all for just
> waiting for the server to send the error.

Makes sense to me.

--b.
