Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:49536 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754220AbbCaP6Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2015 11:58:24 -0400
Date: Tue, 31 Mar 2015 11:58:24 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        Greg KH <gregkh@linuxfoundation.org>, trond.myklebust@primarydata.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] sunrpc: make debugfs file creation failure non-fatal
Message-ID: <20150331155824.GL6901@fieldses.org>
References: <1427752698-32431-1-git-send-email-jeff.layton@primarydata.com>
 <20150330234753.GG6901@fieldses.org>
 <20150331140916.GJ6901@fieldses.org>
 <20150331142641.GA9961@kroah.com>
 <20150331111146.5b71b395@synchrony.poochiereds.net>
 <551AC1B9.60205@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <551AC1B9.60205@plexistor.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 31, 2015 at 06:48:09PM +0300, Boaz Harrosh wrote:
> On 03/31/2015 06:11 PM, Jeff Layton wrote:
> > On Tue, 31 Mar 2015 16:26:41 +0200
> > Greg KH <gregkh@linuxfoundation.org> wrote:
> > 
> <>
> > We certainly can update the selinux policy to allow gssproxy to do
> > this, but:
> > 
> 
> Or can we update the selinux policy to allow any user access to
> debugfs, since as you said it is always Kernel created ?

As I said, it's actually directory search permissions that selinux is
denying.

Denying gss-proxy permissions to read debugfs actually sounds reasonable
to me--most daemons probably don't need to read debugfs, so why take the
chance there might be some inadvertent information exposure in debugfs
that could be useful to an attacker?

--b.
