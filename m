Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:21081 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751093AbdFTTeN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jun 2017 15:34:13 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH 1/1] [RFC] 64bit copy_file_range system call
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170619193903.GA12803@infradead.org>
Date: Tue, 20 Jun 2017 15:33:39 -0400
Cc: Olga Kornievskaia <aglo@umich.edu>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Olga Kornievskaia <kolga@netapp.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <3836534F-8360-4EF4-926B-C5322A44D95E@oracle.com>
References: <5bca6687-ac03-72ef-f38e-6759a0fbb1d6@gmail.com> <20170614185335.58193-1-kolga@netapp.com> <20170615035923.GA4521@birch.djwong.org> <CAN-5tyGCYjR4wXkpjD8XKXSSAmSS1VG2SA1Kr4V5iJFPjZJFug@mail.gmail.com> <20170615205357.GA13715@birch.djwong.org> <CAN-5tyFSw7CzfpH0=+KW94Z5fHmeOTvG1=7hXsd7nNcaAzre6Q@mail.gmail.com> <20170619193903.GA12803@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 19, 2017, at 3:39 PM, Christoph Hellwig <hch@infradead.org> wrote:
> 
> On Mon, Jun 19, 2017 at 02:34:58PM -0400, Olga Kornievskaia wrote:
>> Yes NFS community does need one for doing a server-to-server copy
>> (performance) feature.
> 
> s/NFS community/NetApp/

I don't have an opinion on the API details, but Oracle is interested
in server-to-server copy, especially if there is an implementation
of it in the Linux NFS server.


--
Chuck Lever



