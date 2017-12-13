Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35536 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753471AbdLMChu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Dec 2017 21:37:50 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Christoph Hellwig" <hch@infradead.org>
Cc: "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "Anna Schumaker" <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 0/3] pNFS blocklayout handling for transient devices
Date: Tue, 12 Dec 2017 21:37:48 -0500
Message-ID: <14753E3B-BDB8-44A8-95BB-9354BCECBC49@redhat.com>
In-Reply-To: <20171212142900.GB25596@infradead.org>
References: <cover.1512748321.git.bcodding@redhat.com>
 <20171212142900.GB25596@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12 Dec 2017, at 9:29, Christoph Hellwig wrote:

> On Fri, Dec 08, 2017 at 12:52:56PM -0500, Benjamin Coddington wrote:
>> This set improves the blocklayoutdriver's handling of layouts when 
>> devices
>> are not present on the a client, or become unavailable.  Ideally, 
>> clients
>> should not continually spam a server with LAYOUTGET for known 
>> layouts, and
>> GETDEVINFO for known devices, since it may be a common scenario to 
>> have some
>> clients that have access to the block devices, and some clients that 
>> do not.
>>
>> In addition to better handling situations where devices are 
>> unavailable,
>> patches 2 and 3 fix crashes if SCSI devices do not exist or are 
>> already have
>> existing reservations.
>
> What testcases do you have for this?

The simplest reproduction of a problem would be to try to mount without
having the block devices present at all.  That pops -EIO to the 
application
instead of falling back to the MDS.

I've run this through the NFS cthon and xfstests while using iscsiadm to
login/logout of a discovered target every second.  This conveniently
adds/removes the block devices repeatedly during the test.. something 
like:

while true; do
     iscsiadm -m node -T 
iqn.2003-01.org.linux-iscsi.godel.x8664:sn.0770b0253b97 --logout
     sleep 1;
     iscsiadm -m node -T 
iqn.2003-01.org.linux-iscsi.godel.x8664:sn.0770b0253b97 --login
done

I don't have recent memory of a way to reproduce the crashes I saw.. I'd
have to go back several months to when I first noted a problem.  If
necessary I can do some work to dredge them up.

Ben
