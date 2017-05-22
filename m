Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:34104 "EHLO
        mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752536AbdEVMy7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 May 2017 08:54:59 -0400
Received: by mail-qk0-f176.google.com with SMTP id k74so104807071qke.1
        for <linux-nfs@vger.kernel.org>; Mon, 22 May 2017 05:54:59 -0700 (PDT)
Message-ID: <1495457696.2816.2.camel@redhat.com>
Subject: Re: [PATCH v2 01/10] SUNRPC: add AF_VSOCK support to addr.[ch]
From: Jeff Layton <jlayton@redhat.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Cc: linux-nfs@vger.kernel.org,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Date: Mon, 22 May 2017 08:54:56 -0400
In-Reply-To: <20170522122105.GH12205@stefanha-x1.localdomain>
References: <1475834514-4058-1-git-send-email-stefanha@redhat.com>
         <1475834514-4058-2-git-send-email-stefanha@redhat.com>
         <1495116264.3956.3.camel@redhat.com>
         <20170522122105.GH12205@stefanha-x1.localdomain>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2017-05-22 at 13:21 +0100, Stefan Hajnoczi wrote:
> On Thu, May 18, 2017 at 10:04:24AM -0400, Jeff Layton wrote:
> > On Fri, 2016-10-07 at 11:01 +0100, Stefan Hajnoczi wrote:
> > > @@ -249,6 +302,10 @@ size_t rpc_pton(struct net *net, const char *buf, const size_t buflen,
> > >  {
> > >  	unsigned int i;
> > >  
> > > +	/* TODO is there a nicer way to distinguish vsock addresses? */
> > > +	if (strncmp(buf, "vsock:", 6) == 0)
> > > +		return rpc_pton_vsock(buf, buflen, sap, salen);
> > > +
> > 
> > Ick, what if I have a host on the network named "vsock"? I think you'll
> > need to come up with a different way to do this.
> 
> There is no collision.  This function doesn't do name resolution and no
> valid IPv4/IPv6 address starts with "vsock:".
> 

Doh! Of course... :)

> I am open to suggestions for a cleaner way of doing it though :).

Does lsof recognize vsock sockets? How does it format them?
-- 
Jeff Layton <jlayton@redhat.com>
