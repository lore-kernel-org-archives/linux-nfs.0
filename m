Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:38109 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751308AbdFXL3K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 24 Jun 2017 07:29:10 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 1FF282807F3
        for <linux-nfs@vger.kernel.org>; Sat, 24 Jun 2017 13:29:09 +0200 (CEST)
Date: Sat, 24 Jun 2017 13:29:04 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Christoph Hellwig <hch@infradead.org>
Cc: Olga Kornievskaia <aglo@umich.edu>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Olga Kornievskaia <kolga@netapp.com>,
        linux-fsdevel@vger.kernel.org,
        linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <754230287.18005788.1498303744540.JavaMail.zimbra@desy.de>
In-Reply-To: <20170619193903.GA12803@infradead.org>
References: <5bca6687-ac03-72ef-f38e-6759a0fbb1d6@gmail.com> <20170614185335.58193-1-kolga@netapp.com> <20170615035923.GA4521@birch.djwong.org> <CAN-5tyGCYjR4wXkpjD8XKXSSAmSS1VG2SA1Kr4V5iJFPjZJFug@mail.gmail.com> <20170615205357.GA13715@birch.djwong.org> <CAN-5tyFSw7CzfpH0=+KW94Z5fHmeOTvG1=7hXsd7nNcaAzre6Q@mail.gmail.com> <20170619193903.GA12803@infradead.org>
Subject: Re: [PATCH 1/1] [RFC] 64bit copy_file_range system call
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



----- Original Message -----
> From: "Christoph Hellwig" <hch@infradead.org>
> To: "Olga Kornievskaia" <aglo@umich.edu>
> Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, "Olga Kornievskaia" <kolga@netapp.com>, linux-fsdevel@vger.kernel.org,
> "linux-nfs" <linux-nfs@vger.kernel.org>
> Sent: Monday, June 19, 2017 9:39:03 PM
> Subject: Re: [PATCH 1/1] [RFC] 64bit copy_file_range system call

> On Mon, Jun 19, 2017 at 02:34:58PM -0400, Olga Kornievskaia wrote:
>> Yes NFS community does need one for doing a server-to-server copy
>> (performance) feature.
> 
> s/NFS community/NetApp/

As being probably the first person who have raised the need in server-to-server copy 
in NFS (see slide 15 http://nfsv4bat.org/Documents/ConnectAThon/2008/managedstorage.pdf),
let me disagree with you.

Having end-user hat on me I can say, that over a decade we are moving scientific
data around the world with server-side-copy, or 3rd-party copy as we call
it. While we more-and-more use NFS (pNFS) for data access, we always need a
second protocol, like FTP or WebDAV, to perform efficient data movement.

I am not deep in kernel internals, but there must be a very good reason to block
such functionality in NFS. Such functionality will drastically simplify our
workflow. And I am sure, we are not the only users of it. 

Tigran.


> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
