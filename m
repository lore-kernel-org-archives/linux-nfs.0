Return-Path: <SRS0=saDi=QU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7111C282C2
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Feb 2019 07:24:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 976FE222C2
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Feb 2019 07:24:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550042677;
	bh=GtZX0E2d2zpA7eJ4EF/lqGYorRr55jaLOiLnb5gXB3k=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=xtF0a+U6MyJkQwfZ8pXJfveeyhI9M1kg5nQ83mqEhMQZbCEd4zrloepzKFRxJG1JQ
	 E/PpDiMEaTJfwyUWUL/9uarXwOZJdIhgAkdOHadZE8T+N7D0BMIerQ1M7rTeo168FZ
	 BhVs81QHA7ioNx4vyDc+838PrmEKtPJoJbKkjcEk=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1733169AbfBMHYh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 13 Feb 2019 02:24:37 -0500
Received: from mail.kernel.org ([198.145.29.99]:43982 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1732277AbfBMHYg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 13 Feb 2019 02:24:36 -0500
Received: from localhost (5356596B.cm-6-7b.dynamic.ziggo.nl [83.86.89.107])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 94237222B5;
        Wed, 13 Feb 2019 07:24:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1550042676;
        bh=GtZX0E2d2zpA7eJ4EF/lqGYorRr55jaLOiLnb5gXB3k=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=xzC4mfsxLEwxqklPPFpjSz2ZMVrXolfn72pJiIgL0ujZONQFOlF5+ANd60AehDSOp
         daOR034EuHjUQVE4ZS6OJZ/DOcQaC7yRz9sUzb11EPRCEg8b3gzgs1nk76x2Hetxcl
         QzuWGsUBz5Pn8zOy1ZjyUdZpAO+S7CxwWmItDVjw=
Date:   Wed, 13 Feb 2019 08:24:33 +0100
From:   "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
To:     "Schumaker, Anna" <Anna.Schumaker@netapp.com>
Cc:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "trond.myklebust@hammerspace.com" <trond.myklebust@hammerspace.com>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "dhowells@redhat.com" <dhowells@redhat.com>
Subject: Re: [PATCH] rpc: properly check debugfs dentry before using it
Message-ID: <20190213072433.GA10225@kroah.com>
References: <20190212182734.GA4509@kroah.com>
 <2a029733e094460e2f57bb2d3fc28e7e1757b83e.camel@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2a029733e094460e2f57bb2d3fc28e7e1757b83e.camel@netapp.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Feb 12, 2019 at 08:52:53PM +0000, Schumaker, Anna wrote:
> On Tue, 2019-02-12 at 19:27 +0100, Greg Kroah-Hartman wrote:
> > debugfs can now report an error code if something went wrong instead of
> > just NULL.  So if the return value is to be used as a "real" dentry, it
> > needs to be checked if it is an error before dereferencing it.
> > 
> > This is now happening because of ff9fb72bc077 ("debugfs: return error
> > values, not NULL"), but why debugfs files are not being created properly
> > is an older issue, probably one that has always been there and should
> > probably be looked at...
> > 
> > Cc: "J. Bruce Fields" <bfields@fieldses.org>
> > Cc: Jeff Layton <jlayton@kernel.org>
> > Cc: Trond Myklebust <trond.myklebust@hammerspace.com>
> > Cc: Anna Schumaker <anna.schumaker@netapp.com>
> > Cc: linux-nfs@vger.kernel.org
> > Cc: netdev@vger.kernel.org
> > Reported-by: David Howells <dhowells@redhat.com>
> > Tested-by: David Howells <dhowells@redhat.com>
> > Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > 
> > ---
> >  net/sunrpc/debugfs.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > I can take this through my tree if people don't object, or it can go
> > through the NFS tree.  It does need to get merged before 5.0-final
> > though.
> 
> I'm planning another bugfixes pull for 5.0, so I can take this patch and send it
> with the others this week.

Wonderful, thanks for doing this, and sorry for the regression.

greg k-h
