Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52618 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751021AbdFTMiw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Jun 2017 08:38:52 -0400
Subject: Re: [PATCH 1/1] [RFC] 64bit copy_file_range system call
To: Christoph Hellwig <hch@infradead.org>,
        Olga Kornievskaia <aglo@umich.edu>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>,
        Olga Kornievskaia <kolga@netapp.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
References: <5bca6687-ac03-72ef-f38e-6759a0fbb1d6@gmail.com>
 <20170614185335.58193-1-kolga@netapp.com>
 <20170615035923.GA4521@birch.djwong.org>
 <CAN-5tyGCYjR4wXkpjD8XKXSSAmSS1VG2SA1Kr4V5iJFPjZJFug@mail.gmail.com>
 <20170615205357.GA13715@birch.djwong.org>
 <CAN-5tyFSw7CzfpH0=+KW94Z5fHmeOTvG1=7hXsd7nNcaAzre6Q@mail.gmail.com>
 <20170619193903.GA12803@infradead.org>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <a1fde577-8ab7-70ba-dab1-f19a147113cd@RedHat.com>
Date: Tue, 20 Jun 2017 08:38:49 -0400
MIME-Version: 1.0
In-Reply-To: <20170619193903.GA12803@infradead.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On 06/19/2017 03:39 PM, Christoph Hellwig wrote:
> On Mon, Jun 19, 2017 at 02:34:58PM -0400, Olga Kornievskaia wrote:
>> Yes NFS community does need one for doing a server-to-server copy
>> (performance) feature.
> 
> s/NFS community/NetApp/
Wrong... Red Hat is also very interested in this work
being that this support is in both Fedora and upcoming 
RHEL releases... 

I must admin I just don't understand what there is *any*
push back on a feature that would dramatically increase
the I/O speed of NFS. That would be good for the
*entire* Linux community... IMHO.

I'm coming to the party late... So is the only
sticking point is to have this vfs call 
write to a different filesystem, correct?
Why? (please point to a email that already
explains it) Does that break some type of
boundary or is it because it was never
needed before??  

Again, looking at the big picture... Allowing
NFS to copy files by only sending meta-data 
is HUGE! It is such a win for the entire 
community so I'm so surprise this community 
is not trying to help the process instead
of push it back.

my two cents,

steved.
 
