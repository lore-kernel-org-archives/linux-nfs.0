Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:27024 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759261Ab3BVSKY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Feb 2013 13:10:24 -0500
Date: Fri, 22 Feb 2013 13:10:18 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <steved@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] NFSDv4.2: Added NFS v4.2 support to the NFS server
Message-ID: <20130222181018.GC10846@pad.fieldses.org>
References: <1361552981-29385-1-git-send-email-steved@redhat.com>
 <1361552981-29385-3-git-send-email-steved@redhat.com>
 <20130222180515.GA30856@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130222180515.GA30856@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 22, 2013 at 01:05:15PM -0500, J. Bruce Fields wrote:
> On Fri, Feb 22, 2013 at 12:09:41PM -0500, Steve Dickson wrote:
> > This enable NFSv4.2 support for the server. To enable this
> > code do the following:
> >   echo "+4.2" >/proc/fs/nfsd/versions
> 
> Give it a config option and we're set....

Also, while you're testing these: worth firing up wireshark and checking
that "2"'s actually being sent in minorversion field, both on ordinary
compounds and on callbacks.

--b.
