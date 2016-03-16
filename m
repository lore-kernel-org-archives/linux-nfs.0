Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:35407 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751235AbcCPD3F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Mar 2016 23:29:05 -0400
MIME-Version: 1.0
In-Reply-To: <20160315201700.GA22945@sernet.de>
References: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
 <20160311140134.GA14808@infradead.org> <CAHc6FU4t3yisCM=MXrHRmCja_A8eZOpVa1smJ0gUhv+vuUAuXA@mail.gmail.com>
 <20160315071103.GC19747@infradead.org> <20160315154514.GB39038@jra3> <20160315201700.GA22945@sernet.de>
From: Steve French <smfrench@gmail.com>
Date: Tue, 15 Mar 2016 22:28:44 -0500
Message-ID: <CAH2r5mt1SBnxnu=c8JGA1dmUUcHXG+wYXfWFQCcbC1tZT0BHpQ@mail.gmail.com>
Subject: Re: [PATCH v18 00/22] Richacls (Core and Ext4)
To: "Volker.Lendecke@sernet.de" <Volker.Lendecke@sernet.de>
Cc: Cristoph Hellwig <hch@infradead.org>, Jeremy Allison <jra@samba.org>,
        Andreas Gruenbacher <agruenba@redhat.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "Theodore Ts'o" <tytso@mit.edu>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        LKML <linux-kernel@vger.kernel.org>, XFS Developers <xfs@oss.sgi.com>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 15, 2016 at 3:17 PM, Volker Lendecke
<Volker.Lendecke@sernet.de> wrote:
> On Tue, Mar 15, 2016 at 08:45:14AM -0700, Jeremy Allison wrote:
>> On Tue, Mar 15, 2016 at 12:11:03AM -0700, Christoph Hellwig wrote:
>> > People have long learned that we only have 'alloc' permissions.  Any
>> > model that mixes allow and deny ACE is a mistake.
>>
>> People can also learn and change though :-). One of the
>> biggest complaints people deploying Samba on Linux have is the
>> incompatible ACL models.
>
> Just to confirm: I see this a lot in the field. NFSv4 ACLs, while not a
> perfect match for NTFS ACLs are a lot closer much more usable to people
> who want to serve Windows clients.

Yes (and presumably Macs as well)



-- 
Thanks,

Steve
