Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:6617 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932692AbcK2VCm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 29 Nov 2016 16:02:42 -0500
Subject: Re: [PATCH v2 0/4] Add copy_file_range() tests
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>
References: <20160907195619.25914-1-Anna.Schumaker@Netapp.com>
 <20161026082638.GA19419@infradead.org> <20161125080509.GA6082@infradead.org>
 <20161129204722.GA9331@fieldses.org>
CC: <fstests@vger.kernel.org>, <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <ce1c4ee0-eaa9-1011-857a-c4930bb12115@Netapp.com>
Date: Tue, 29 Nov 2016 15:59:29 -0500
MIME-Version: 1.0
In-Reply-To: <20161129204722.GA9331@fieldses.org>
Content-Type: text/plain; charset="windows-1252"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry for the delay!  I've been busy looking at other things and forgot to update the copy_file_range() stuff :(

On 11/29/2016 03:47 PM, J. Bruce Fields wrote:
> On Fri, Nov 25, 2016 at 12:05:10AM -0800, Christoph Hellwig wrote:
>> On Wed, Oct 26, 2016 at 01:26:38AM -0700, Christoph Hellwig wrote:
>>> On Wed, Sep 07, 2016 at 03:56:15PM -0400, Anna Schumaker wrote:
>>>> These tests exercise the copy_file_range() system call, and check copying
>>>> data to both a new file and overwriting data inside an existing file.  I use
>>>> the xfs_io "copy_range" command for the actual copies, so running these
>>>> tests requires an up-to-date version of xfsprogs.
>>>
>>> Hi Anna,
>>>
>>> what's the status of these tests?  Did you get a chance to look
>>> into xfs_io copyfile support?

xfs_io has support for copying now, so I'll make sure that the tests use that correctly.  I promise to send out an update this week, once I check that everything still works!

Thanks for the reminders,
Anna

>>
>> Another month, another ping - it would be really sad to not have any
>> real testing for copy_file_range.
> 
> Agreed, Anna, are you still planning on doing this?
> 
> --b.
> 
>> I've been holding a pending change
>> for it back for month now because I want to verify it more than cursory,
>> but I guess I'll just have to send it anyway.
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
