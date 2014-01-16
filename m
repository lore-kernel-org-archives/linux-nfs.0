Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.infotech.no ([82.134.31.41]:47013 "EHLO smtp.infotech.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751388AbaAPAqj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jan 2014 19:46:39 -0500
Message-ID: <52D72BEA.4050200@interlog.com>
Date: Wed, 15 Jan 2014 19:46:34 -0500
From: Douglas Gilbert <dgilbert@interlog.com>
Reply-To: dgilbert@interlog.com
MIME-Version: 1.0
To: "Nicholas A. Bellinger" <nab@linux-iscsi.org>, Zach Brown <zab@redhat.com>
CC: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-scsi@vger.kernel.org,
        Hannes Reinecke <hare@suse.de>
Subject: Re: [LSF/MM TOPIC] copy offloading
References: <20140115202754.GL8102@lenny.home.zabbo.net> <1389827455.5567.602.camel@haakon3.risingtidesystems.com>
In-Reply-To: <1389827455.5567.602.camel@haakon3.risingtidesystems.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 14-01-15 06:10 PM, Nicholas A. Bellinger wrote:
> On Wed, 2014-01-15 at 12:27 -0800, Zach Brown wrote:
>> Discussing copy offloading at LSF is appropriate because it can involve
>> so many layers of the stack:
>>
>>   - high level syscall interface
>>   - in-kernel high level entry point for nfsd
>>   - fs specific implementations (btrfs and ocfs2 cow, nfs)
>>   - vfs helper for offloading block copies for ext*,xfs
>>   - bio offload requests for cow block devices like bcache/dm-cache
>>   - encoding offload bios into scsi reqs
>>   - processing virt guest device offload requests with host syscalls
>>
>> Getting the user and in-kernel interfaces right to support all these
>> moving parts has proven tricky.  The more input, the better.
>>
>> It's been a while since I sent out a refreshed version of the series.
>> That'll be remedied before LSF rolls around :).
>>
>
> +1
>
> Now that EXTENDED_COPY LID1 target mode logic is upstream, I'm really
> eager to start utilizing it Linux host side.  ;)

Hannes Reinecke and I are preparing a proposal for a
talk about ODX (a Microsoft acronym: offloaded data
transfer) also know as "xcopy version 2, lite" by HP.

ODX is a subset of the SCSI xcopy(LID4) for disk to disk
copies. It uses the new SBC-3 POPULATE TOKEN and WRITE
USING TOKEN commands. Most uses of xcopy(LID1) today are
also disk to disk copies so ODX can be considered as an
enhancement.

There is nothing wrong with xcopy(LID1); at around 15
years old it has been a little slow to gain traction.
While we have the file system guys' attention, why not
show them some new tricks that ODX can do?


Consider this: (virtual) machines A and B share a storage
device that supports ODX; machine A wants to send a large
file to machine B. Machine A can do a POPULATE TOKEN with
a gather list and gets back a "ROD _token_" which is around
512 bytes long. It writes that ROD token to a file and
uses the network to send that file to machine B. Then
machine B calls WRITE USING TOKEN with that ROD token
and supplies a scatter list (where it wants to write).

The actual ROD (representation of data) was created
by the POPULATE TOKEN command and is sitting in
storage device with "point in time" semantics. This
trick doesn't depend on a common storage device:
several storage devices that support xcopy(LID4) and
that share a SCSI domain can "talk amongst themselves"
to effect a ROD based copy of data.

We also plan to have a Linux utility showing ODX
in action.

Doug Gilbert


BTW LID1 and LID4 are simply SCSI/T10 jargon often used
     to distinguish the older generation of xcopy from
     the recent version. Both will be supported when
     SPC-4 and SBC-3 become standards, probably later
     this year. "LID1" actually means a "list identifier
     length of 1 byte", guess what LID4 stands for.

