Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:60287 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753262Ab3HVVW3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Aug 2013 17:22:29 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 5 1/3] NFSv4 Remove unused LIPKEY and SPKM enums
Date: Thu, 22 Aug 2013 21:22:27 +0000
Message-ID: <75493002-76E0-45C1-9AC6-68B9300ED200@netapp.com>
References: <1376430469-3773-1-git-send-email-andros@netapp.com>
 <1376430469-3773-2-git-send-email-andros@netapp.com>
 <1377197453.11488.32.camel@leira.trondhjem.org>
In-Reply-To: <1377197453.11488.32.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 22, 2013, at 2:50 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com>
 wrote:

> On Tue, 2013-08-13 at 17:47 -0400, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>> 
>> SPKM and LIPKEY are not supported.
> 
> We don't ship with SPKM and LIPKEY, but afaik nothing prevents someone
> from adding support again.

I think that the lack of an internet draft will prevent someone from adding support again. draft-adamson-rfc2847-bis-01.txt was the last attempt to fix SPKM3 - and was rejected by the Security AD after much debate. It died in Aug 2006. So, there is no standard to code to. 

So I see no need to keep these un-used declarations around.

-->Andy

> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

