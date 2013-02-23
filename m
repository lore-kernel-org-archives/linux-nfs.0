Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:44668 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758876Ab3BWMn4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 23 Feb 2013 07:43:56 -0500
Message-ID: <5128B97F.6040301@RedHat.com>
Date: Sat, 23 Feb 2013 07:43:43 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] NFSDv4.2: Added NFS v4.2 support to the NFS server
References: <1361552981-29385-1-git-send-email-steved@redhat.com> <1361552981-29385-3-git-send-email-steved@redhat.com> <20130222180515.GA30856@fieldses.org>
In-Reply-To: <20130222180515.GA30856@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 22/02/13 13:05, J. Bruce Fields wrote:
> On Fri, Feb 22, 2013 at 12:09:41PM -0500, Steve Dickson wrote:
>> > This enable NFSv4.2 support for the server. To enable this
>> > code do the following:
>> >   echo "+4.2" >/proc/fs/nfsd/versions
> Give it a config option and we're set....
I didn't a config option in fs/nfsd/Kconfig for 4.1 which is 
the reason I didn't add one for 4.2... Should I add both?

steved.
