Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56949 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932901Ab1CWUf3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Mar 2011 16:35:29 -0400
Subject: Re: [PATCH 09/12] NFSv4.1: remove GETATTR from ds commits
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Fred Isaman <iisaman@netapp.com>
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org
In-Reply-To: <AANLkTi=_+22+7-bw_Y7q4NpF16B7G3wNin7r7EkJNg7n@mail.gmail.com>
References: <1300886875-5016-1-git-send-email-iisaman@netapp.com>
	 <1300886875-5016-10-git-send-email-iisaman@netapp.com>
	 <4D8A4F2B.5040007@panasas.com>
	 <AANLkTi=_+22+7-bw_Y7q4NpF16B7G3wNin7r7EkJNg7n@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 23 Mar 2011 16:35:09 -0400
Message-ID: <1300912509.11677.70.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-03-23 at 16:32 -0400, Fred Isaman wrote:
> 2011/3/23 Benny Halevy <bhalevy@panasas.com>:
> > On 2011-03-23 15:27, Fred Isaman wrote:
> >> Any COMMIT compound directed to a data server needs to have the
> >> GETATTR calls suppressed.  We here, make sure the field we are testing
> >
> > s/We/While/?
> >
> 
> Yes.
> 
> Fred

Too late. That typo is already committed.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

