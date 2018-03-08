Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44140 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750896AbeCHUYY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Mar 2018 15:24:24 -0500
Date: Thu, 8 Mar 2018 15:24:23 -0500
To: Chuck Lever <chucklever@gmail.com>
Cc: Guillem Jover <gjover@sipwise.com>,
        libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Do not bind to reserved ports registered in /etc/services
Message-ID: <20180308202423.GA16485@fieldses.org>
References: <20180110004920.11100-1-gjover@sipwise.com>
 <e18f29cd-639d-be9d-ee93-80df592468db@RedHat.com>
 <20180112184151.GA10261@thunder.hadrons.org>
 <9a53753a-56bf-12b5-f328-ff1f3a72249d@talpey.com>
 <CAFMMQGv03UmmsyXF4BOrwgW9ngpeO=dLjv=Qt=YiPpvgxfo85A@mail.gmail.com>
 <D9BFFDFE-B80F-4220-9A54-F09F882BD0A1@gmail.com>
 <CAFMMQGtt_u19RoCyQAQEaSZRXu3WQ-YSKu4u1BtKtJnaTQbKYw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAFMMQGtt_u19RoCyQAQEaSZRXu3WQ-YSKu4u1BtKtJnaTQbKYw@mail.gmail.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 06, 2018 at 01:09:01PM -0500, Chuck Lever wrote:
> Note that neither of these solutions addresses the largest consumer
> of dynamically-assigned reserved ports: the kernel NFS client. The
> only way we have to address that today is the "noresvport" mount
> option. (We could make that the default for Kerberos mounts).

Makes sense to me.

Looks like knfsd's not helpful here, though: the export option
("secure"/"insecure") defaults to "secure", which always requires a low
port.  It should be easy to modify "secure" to mean "require low ports
only for auth_sys/auth_null", and that's probably the right thing to do.

--b.
