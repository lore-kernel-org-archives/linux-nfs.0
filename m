Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:33584 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751041AbdFTThp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jun 2017 15:37:45 -0400
MIME-Version: 1.0
In-Reply-To: <3836534F-8360-4EF4-926B-C5322A44D95E@oracle.com>
References: <5bca6687-ac03-72ef-f38e-6759a0fbb1d6@gmail.com>
 <20170614185335.58193-1-kolga@netapp.com> <20170615035923.GA4521@birch.djwong.org>
 <CAN-5tyGCYjR4wXkpjD8XKXSSAmSS1VG2SA1Kr4V5iJFPjZJFug@mail.gmail.com>
 <20170615205357.GA13715@birch.djwong.org> <CAN-5tyFSw7CzfpH0=+KW94Z5fHmeOTvG1=7hXsd7nNcaAzre6Q@mail.gmail.com>
 <20170619193903.GA12803@infradead.org> <3836534F-8360-4EF4-926B-C5322A44D95E@oracle.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 20 Jun 2017 15:37:43 -0400
Message-ID: <CAN-5tyHQiVD5vBz_P0Rc4fN1eFf9s4tQm=Lo+YcdhgzEnSmwwQ@mail.gmail.com>
Subject: Re: [PATCH 1/1] [RFC] 64bit copy_file_range system call
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Olga Kornievskaia <kolga@netapp.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 20, 2017 at 3:33 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
>> On Jun 19, 2017, at 3:39 PM, Christoph Hellwig <hch@infradead.org> wrote:
>>
>> On Mon, Jun 19, 2017 at 02:34:58PM -0400, Olga Kornievskaia wrote:
>>> Yes NFS community does need one for doing a server-to-server copy
>>> (performance) feature.
>>
>> s/NFS community/NetApp/
>
> I don't have an opinion on the API details, but Oracle is interested
> in server-to-server copy, especially if there is an implementation
> of it in the Linux NFS server.

The proposed patch set is the linux client AND linux server. We need
removal of the VFS cross-device check on both side (client and
destination server) to make the server-to-server copy work. On the
server side, we also call vfs_copy_file_range() that (when check is
removed) ends up reading from the NFS source file and writing to the
local file system.
