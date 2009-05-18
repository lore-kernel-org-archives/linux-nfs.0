From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/3] nfs-utils: nfsd support for minor version, take 2
Date: Mon, 18 May 2009 10:49:08 -0400
Message-ID: <4A117564.2090602@RedHat.com>
References: <49E2F6E4.2080501@panasas.com> <49EF0846.5030800@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	Chuck Lever <chuck.lever@oracle.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:33605 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750927AbZEROwS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 May 2009 10:52:18 -0400
In-Reply-To: <49EF0846.5030800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry it took so long...  

Benny Halevy wrote:
> Following the discussion we had last week
> (see http://linux-nfs.org/pipermail/pnfs/2009-April/007283.html)
> 
> I made the following changes:
> * minorvers4 enabled by default.
> * No new -n option.
> 
> This makes minorvers control essentially the same as
> the major protocol version.  minorvers4 is enabled by default
> and can be disabled using -N 4.1.
> 
> On Fedora, /etc/sysconfig/nfs can be changed as follows
> to configure the service startup script to disable 4.1:
Committed... 

steved.
