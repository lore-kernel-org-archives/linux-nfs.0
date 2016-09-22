Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:33532 "EHLO
        mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752372AbcIVLHH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2016 07:07:07 -0400
Received: by mail-qk0-f175.google.com with SMTP id g67so12146898qkd.0
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2016 04:07:07 -0700 (PDT)
Message-ID: <1474542423.1706.4.camel@redhat.com>
Subject: Re: [0/2] make nfsd's setclientid behavior migration-friendly
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Date: Thu, 22 Sep 2016 07:07:03 -0400
In-Reply-To: <1474481025-23702-1-git-send-email-bfields@redhat.com>
References: <1474481025-23702-1-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2016-09-21 at 14:03 -0400, J. Bruce Fields wrote:
> Clients mounting multiple servers with the "migration" option may find
> some mounts are made from the incorrect server.
> 
> I think this is really a bug in RFC 7931, and that RFC and the client
> need fixing, but this is easy to mitigate on the server.  I'll make an
> attempt at a client patch too.
> 
> --b.
> 
> 

Both look reasonable to me:

Reviewed-by: Jeff Layton <jlayton@redhat.com>
