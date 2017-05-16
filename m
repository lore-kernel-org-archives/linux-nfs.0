Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59438 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751357AbdEPNg3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 16 May 2017 09:36:29 -0400
Date: Tue, 16 May 2017 09:36:03 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: EXCHANGE_ID with same network address but different server owner
Message-ID: <20170516133603.GA21704@parsley.fieldses.org>
References: <20170512132721.GA654@stefanha-x1.localdomain>
 <20170512143410.GC17983@parsley.fieldses.org>
 <1494601295.10434.1.camel@primarydata.com>
 <021509A5-FA89-4289-B190-26DC317A09F6@oracle.com>
 <20170515144306.GB16013@stefanha-x1.localdomain>
 <20170515160248.GD9697@parsley.fieldses.org>
 <20170516133338.GD8498@stefanha-x1.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170516133338.GD8498@stefanha-x1.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 16, 2017 at 02:33:38PM +0100, Stefan Hajnoczi wrote:
> I suspect many guests will have a dedicated/private export.  The guest
> will be the only client accessing its export.  This could simplify the
> locking issues.

So why not migrate filesystem images instead of using NFS?

--b.
