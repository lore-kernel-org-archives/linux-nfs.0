Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:50960 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760393Ab2EKOcx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 May 2012 10:32:53 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
CC: Lev Solomonov <solo@tonian.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 1/3] NFS: Create an NFS v3 stat_to_errno()
Date: Fri, 11 May 2012 14:32:51 +0000
Message-ID: <EE86D78C-D697-42E7-AD75-3168008B7FFB@netapp.com>
References: <1336682840-10799-1-git-send-email-bjschuma@netapp.com>
 <CAOdHTRDOxOvPo-uAOGNMnF2+Nf+p0Ni0KoaZTvh8kM2QU=r1oQ@mail.gmail.com>
 <4FAD08BE.4060408@netapp.com>
In-Reply-To: <4FAD08BE.4060408@netapp.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Yes, please resend

Cheers
 Trond
--
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

On May 11, 2012, at 8:40 AM, Bryan Schumaker wrote:

> On 05/11/2012 04:12 AM, Lev Solomonov wrote:
> 
>> On Thu, May 10, 2012 at 11:47 PM,  <bjschuma@netapp.com> wrote:
>>> From: Bryan Schumaker <bjschuma@netapp.com>
>>> 
>>> In theory, NFS v3 can have different error versions than NFS v2. v4 is
>>> already using its own nfs4_stat_to_errno() to mapp error codes, so
>> 
>> ^mapp^map ?
> 
> 
> Good catch.  Trond, should I resend the patch?
> 

