Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:34344 "EHLO
        mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750947AbdFSTsQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Jun 2017 15:48:16 -0400
MIME-Version: 1.0
In-Reply-To: <20170619193903.GA12803@infradead.org>
References: <5bca6687-ac03-72ef-f38e-6759a0fbb1d6@gmail.com>
 <20170614185335.58193-1-kolga@netapp.com> <20170615035923.GA4521@birch.djwong.org>
 <CAN-5tyGCYjR4wXkpjD8XKXSSAmSS1VG2SA1Kr4V5iJFPjZJFug@mail.gmail.com>
 <20170615205357.GA13715@birch.djwong.org> <CAN-5tyFSw7CzfpH0=+KW94Z5fHmeOTvG1=7hXsd7nNcaAzre6Q@mail.gmail.com>
 <20170619193903.GA12803@infradead.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Mon, 19 Jun 2017 15:48:14 -0400
Message-ID: <CAN-5tyFxuuPDqQ2osmNWZnovhWWtoV8P96vgB9spt_YMFReLZA@mail.gmail.com>
Subject: Re: [PATCH 1/1] [RFC] 64bit copy_file_range system call
To: Christoph Hellwig <hch@infradead.org>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>,
        Olga Kornievskaia <kolga@netapp.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 19, 2017 at 3:39 PM, Christoph Hellwig <hch@infradead.org> wrote:
> On Mon, Jun 19, 2017 at 02:34:58PM -0400, Olga Kornievskaia wrote:
>> Yes NFS community does need one for doing a server-to-server copy
>> (performance) feature.
>
> s/NFS community/NetApp/

NetApp = users. Is there another reason for having a feature in the
kernel if not for the users?
