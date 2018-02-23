Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35338 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933089AbeBWSpa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Feb 2018 13:45:30 -0500
Subject: Re: [PATCH 1/1] NFS guard against incorrect vers inputs from
 nfs-utils
To: Olga Kornievskaia <aglo@umich.edu>,
        Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
References: <20180222192806.67911-1-kolga@netapp.com>
 <034fb5f1-eba5-030b-aad2-6ac5e87f2066@RedHat.com>
 <CAN-5tyE2wqrgkQuHSFy7=EDricmx6jPKA9=PnqSdf8rr_0rxwQ@mail.gmail.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <6e314995-964f-e70d-cc45-fc1716b4ec81@RedHat.com>
Date: Fri, 23 Feb 2018 13:45:28 -0500
MIME-Version: 1.0
In-Reply-To: <CAN-5tyE2wqrgkQuHSFy7=EDricmx6jPKA9=PnqSdf8rr_0rxwQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/23/2018 12:05 PM, Olga Kornievskaia wrote:
> On Fri, Feb 23, 2018 at 11:24 AM, Steve Dickson <SteveD@redhat.com> wrote:
>> Hey Olga,
>>
>> On 02/22/2018 02:28 PM, Olga Kornievskaia wrote:
>>> It is possible that userland can pass to the kernel mismatching
>>> inputs for the minorversion. like vers=4.1,minorversion=0. Instead
>>> of making the kernel responposible for 'choosing' the minorversion,
>>> make the userland always responsible for not sending a mismatch.
>> I'm thinking this is probably more of mount problem...
> 
> Yes the problem is a broken user land sending incorrect arguments but
> I still think the kernel needs to do sanity checking on arguments to
> prevent this from happening again.
> 
>> mount -t nfs4 -o minorversion=0 server:/export /mnt
>>
>> shouldn't this be a  v4.0 mount instead of a 4.2 mount?
> 
> Yes I would think this should create a v4.0 mount.
Way back when... there was some talk about deprecating 
minorversion= flag... Since it is broken, maybe this is 
a good time to do it?

Thoughts?

steved.
