Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg1-f176.google.com ([209.85.215.176]:46859 "EHLO
        mail-pg1-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726761AbeIKTrG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Sep 2018 15:47:06 -0400
Received: by mail-pg1-f176.google.com with SMTP id b129-v6so12366166pga.13
        for <linux-nfs@vger.kernel.org>; Tue, 11 Sep 2018 07:47:28 -0700 (PDT)
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: Re: lseek gets bad offset from nfs client with ganesha/gluster which
 supports SEEK
To: Trond Myklebust <trondmy@hammerspace.com>,
        "devel@lists.nfs-ganesha.org" <devel@lists.nfs-ganesha.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <182fecd3-66c3-0cbd-fbc0-cf1a88b7f165@gmail.com>
 <182a9c6a29690fc00789768bdfe03affbac0db9e.camel@hammerspace.com>
Message-ID: <53f12a27-e1f5-936f-23e9-58d3cbf7a00f@gmail.com>
Date: Tue, 11 Sep 2018 22:47:16 +0800
MIME-Version: 1.0
In-Reply-To: <182a9c6a29690fc00789768bdfe03affbac0db9e.camel@hammerspace.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 2018/9/11 20:57, Trond Myklebust wrote:
> On Tue, 2018-09-11 at 20:29 +0800, Kinglong Mee wrote:
>> The latest ganesha/gluster supports seek according to,
>>
>>
> https://tools.ietf.org/html/draft-ietf-nfsv4-minorversion2-41#section-15.11
>>
>>    From the given sa_offset, find the next data_content4 of type
>> sa_what
>>    in the file.  If the server can not find a corresponding sa_what,
>>    then the status will still be NFS4_OK, but sr_eof would be
>> TRUE.  If
>>    the server can find the sa_what, then the sr_offset is the start
>> of
>>    that content.  If the sa_offset is beyond the end of the file,
>> then
>>    SEEK MUST return NFS4ERR_NXIO.
>>
>> For a file's filemap as,
>>
>> Part    1: HOLE 0x0000000000000000 ---> 0x0000000000600000
>> Part    2: DATA 0x0000000000600000 ---> 0x0000000000700000
>> Part    3: HOLE 0x0000000000700000 ---> 0x0000000001000000>>
>> SEEK(0x700000, SEEK_DATA) gets result (sr_eof:1, sr_offset:0x70000)
>> from ganesha/gluster;
>> SEEK(0x700000, SEEK_HOLE) gets result (sr_eof:0, sr_offset:0x70000)
>> from ganesha/gluster.
>>
>> If an application depends the lseek result for data searching, it may
>> enter infinite loop.
>>
>>         while (1) {
>>                 next_pos = lseek(fd, cur_pos, seek_type);
>>                 if (seek_type == SEEK_DATA) {
>>                         seek_type = SEEK_HOLE;
>>                 } else {
>>                         seek_type = SEEK_DATA;
>>                 }
>>
>>                 if (next_pos == -1) {
>>                         return ;
>>
>>                 cur_pos = next_pos;
>>         }
>>
>> The lseek syscall always gets 0x70000 from nfs client for those two
>> cases, 
>> but, if underlying filesystem is ext4/f2fs, or the nfs server is
>> knfsd,
>> the lseek(0x700000, SEEK_DATA) gets ENXIO.
>>
>> I wanna to know,
>> should I fix the ganesha/gluster as knfsd return ENXIO for the first
>> case?
>> or should I fix the nfs client to return ENXIO for the first case?
>>
> 
> It that test correct? The fallback implementation of SEEK_DATA assumes
> that the entire file is data, so lseek(SEEK_DATA) on any offset that is
> <= eof will be a no-op. The fallback implementation of SEEK_HOLE
> assumes that the first hole is at eof.

I think that's non-nfsv4.2's logical.

> 
> IOW: unless the initial value for cur_pos is > eof, it looks to me as
> if the above test will loop infinitely given any filesystem that
> doesn't implement native support for SEEK_DATA/SEEK_HOLE.
> 

No, if underlying filesystem is ext4/f2fs, or the nfs server is knfsd,
the last lseek syscall always return ENXIO no matter the cur_pos is > eof or not.

A file ends with a hole as,
Part   22: DATA 0x0000000006a00000 ---> 0x0000000006afffff
Part   23: HOLE 0x0000000006b00000 ---> 0x000000000c7fffff

# stat testfile
  File: testfile
  Size: 209715200       Blocks: 22640      IO Block: 4096   regular file
Device: 807h/2055d      Inode: 843122      Links: 2
Access: (0600/-rw-------)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2018-09-11 20:01:41.881227061 +0800
Modify: 2018-09-11 20:01:41.976478311 +0800
Change: 2018-09-11 20:01:41.976478311 +0800
 Birth: -

# strace filemap testfile
... ...
lseek(3, 111149056, SEEK_HOLE)          = 112197632
lseek(3, 112197632, SEEK_DATA)          = -1 ENXIO (No such device or address)

Right now, when knfsd gets the ENXIO error, it returns the error to client directly,
and return to syscall.
But, ganesha set the sr_eof to true and return NFS4_OK to client as RFC description,
nfs client skips the sr_eof and return a bad offset to syscall.

thanks,
Kinglong Mee
