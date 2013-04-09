Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6927 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935762Ab3DIUFY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Apr 2013 16:05:24 -0400
Subject: Re: [PATCH 0/2] libtirpc and nfs-utils fix for export lucid context
From: Simo Sorce <simo@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        libtirpc-devel@lists.sourceforge.net
In-Reply-To: <51646EF4.5010405@RedHat.com>
References: <1365201425-21702-1-git-send-email-simo@redhat.com>
	 <51646EF4.5010405@RedHat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 09 Apr 2013 16:05:15 -0400
Message-ID: <1365537915.20560.47.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-04-09 at 15:41 -0400, Steve Dickson wrote:
> 
> On 05/04/13 18:37, Simo Sorce wrote:
> > The following 2 patches go in tandem.
> > One is for libtirpc and the other for nfs-utils.
> How backwards compatible are these patches?
> 
> Meaning will a patched nfs-utils work with a non-patch libtirpc and vises versus?
> It appears that is the case... I just want to make sure I'm not missing 
> something... 

As far as I know fully backwards compatible.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

