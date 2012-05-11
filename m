Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55226 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758403Ab2EKMkt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 May 2012 08:40:49 -0400
Message-ID: <4FAD08BE.4060408@netapp.com>
Date: Fri, 11 May 2012 08:40:30 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Lev Solomonov <solo@tonian.com>,
        Trond Myklebust <trond.myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 1/3] NFS: Create an NFS v3 stat_to_errno()
References: <1336682840-10799-1-git-send-email-bjschuma@netapp.com> <CAOdHTRDOxOvPo-uAOGNMnF2+Nf+p0Ni0KoaZTvh8kM2QU=r1oQ@mail.gmail.com>
In-Reply-To: <CAOdHTRDOxOvPo-uAOGNMnF2+Nf+p0Ni0KoaZTvh8kM2QU=r1oQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/11/2012 04:12 AM, Lev Solomonov wrote:

> On Thu, May 10, 2012 at 11:47 PM,  <bjschuma@netapp.com> wrote:
>> From: Bryan Schumaker <bjschuma@netapp.com>
>>
>> In theory, NFS v3 can have different error versions than NFS v2. v4 is
>> already using its own nfs4_stat_to_errno() to mapp error codes, so
> 
> ^mapp^map ?


Good catch.  Trond, should I resend the patch?

