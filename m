Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54266 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754832AbcGEPIS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Jul 2016 11:08:18 -0400
Subject: Re: HA NFS
To: Marc Eshel <eshel@us.ibm.com>
References: <1465939516-44769-1-git-send-email-trond.myklebust@primarydata.com>
 <OF44E4DD0C.FF5B6C3E-ON88257FE2.00771383-88257FE2.007798E3@notes.na.collabserv.com>
 <20160701160857.GB20327@fieldses.org>
 <OF82A5FFDC.3CCEBF40-ON88257FE3.0059C174-88257FE3.00604E03@notes.na.collabserv.com>
 <20160701200742.GA24269@fieldses.org>
 <OF5D486F02.62CECB7B-ON88257FE3.0071DBE5-88257FE3.00722388@notes.na.collabserv.com>
 <20160701210151.GE24269@fieldses.org>
 <OF79A36FEE.749D5EF5-ON88257FE3.007C9721-88257FE3.007CC2B1@notes.na.collabserv.com>
 <20160702005820.GA27063@fieldses.org>
 <OFC1237E53.3CFCA8E8-ON88257FE5.001D3182-88257FE5.001E3A5B@LocalDomain>
 <OF839F4B82.C0113FD6-ON88257FE6.00828B44-88257FE6.008343CD@notes.na.collabserv.com>
Cc: linux-nfs@vger.kernel.org, Tomer Perry <TOMP@il.ibm.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <47ebf941-2e1c-83fc-93e0-b4d70892dc2c@RedHat.com>
Date: Tue, 5 Jul 2016 11:08:17 -0400
MIME-Version: 1.0
In-Reply-To: <OF839F4B82.C0113FD6-ON88257FE6.00828B44-88257FE6.008343CD@notes.na.collabserv.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/04/2016 07:53 PM, Marc Eshel wrote:
> Hi Steve,
> I did not pay attention for a while and now I see that since RHEL7.0 there 
> a major changes in NFSv4 recovery for a signal machine and for cluster 
> file system. Is there any write up on the changes like the use of 
> /var/lib/nfs/nfsdcltrack/main.sqlite, I see it being used in 7.0 but not 
> in 7.2. Any information would be appreciated.

That file is still being used... but there were some changes.

In RHEL 7.2 this was added for bz 1234598
commit c41a3d0a17baa61a07d48d8536e99908d765de9b
Author: Jeff Layton <jlayton@primarydata.com>
Date:   Fri Sep 19 11:07:31 2014 -0400

    nfsdcltrack: fetch NFSDCLTRACK_GRACE_START out of environment


In RHEL 7.3 there will be this for bz 1285097
commit d479ad3adb0671c48d6fbf3e36bd52a31159c413
Author: Jeff Layton <jlayton@primarydata.com>
Date:   Fri Sep 19 11:03:45 2014 -0400

    nfsdcltrack: update schema to v2

I hope this helps... 

steved.
