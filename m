Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39935 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751327AbaGPVoz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jul 2014 17:44:55 -0400
Date: Wed, 16 Jul 2014 17:44:55 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: xdr_get_next_encode_buffer should be declared
 static
Message-ID: <20140716214455.GF2397@fieldses.org>
References: <1405202462-50244-1-git-send-email-trond.myklebust@primarydata.com>
 <20140716205846.GE2397@fieldses.org>
 <CAHQdGtS+0mvbWUJiwYE8ZgsirZ6Baw1q4hZ_TjFjJgX4-HYbmw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtS+0mvbWUJiwYE8ZgsirZ6Baw1q4hZ_TjFjJgX4-HYbmw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 16, 2014 at 02:40:43PM -0700, Trond Myklebust wrote:
> On Wed, Jul 16, 2014 at 1:58 PM, Bruce Fields <bfields@fieldses.org> wrote:
> > On Sat, Jul 12, 2014 at 06:01:02PM -0400, Trond Myklebust wrote:
> >> Quell another sparse warning.
> >
> > I think jlayton sent you the same fix with his set of sunrpc sparse
> > fixes--could you just take that instead?
> >
> > (Or I can take this if you still want, I don't really care.)
> 
> I wasn't planning on carrying either patch in my tree. I've offloaded
> the merge job to you... :-)
> IOW: feel free to take Jeff's patch if that is more convenient.

OK, are you taking the rest of that series or should I get that too?

--b.
