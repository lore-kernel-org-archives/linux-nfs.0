Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35394 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751306AbdBYLQz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 25 Feb 2017 06:16:55 -0500
Received: by mail-io0-f193.google.com with SMTP id v13so1424439iov.2
        for <linux-nfs@vger.kernel.org>; Sat, 25 Feb 2017 03:15:43 -0800 (PST)
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: Re: some problems about permission of subdirectory
To: houlinfei <hou.linfei@h3c.com>
References: <65bb8731.b190.15a5fdf1b2a.Coremail.hou.linfei@h3c.com>
 <29ccb0b1-97fd-1b0b-12c4-3bde03dcdad9@gmail.com>
 <20170224191435.GA26378@fieldses.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.com>,
        Steve Dickson <SteveD@redhat.com>,
        Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <159b79d2-78f5-17e8-5287-069ed7943975@gmail.com>
Date: Sat, 25 Feb 2017 18:45:02 +0800
MIME-Version: 1.0
In-Reply-To: <20170224191435.GA26378@fieldses.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2/25/2017 03:14, J. Bruce Fields wrote:
> On Tue, Feb 21, 2017 at 09:50:01PM +0800, Kinglong Mee wrote:
>> On 2/21/2017 16:52, houlinfei wrote:
>>>
>>> hi everyone:
>>> I met a problem about subdirectory permission when client mount this subdirectory using nfs4. For example:
>>> the contents of the /etc/exports file is
>>> /root/hh *(ro,sync,insecure,no_subtree_check)
>>> /root/hh/hh1 *(rw,sync,insecure,no_subtree_check)
>>> and the two directory permission is 777. And the parent directory's export permission is read-only, the subdirectory's export permission is read-write.
>>> Then client mount /root/hh/hh1 on /mnt/yy using nfs4. But the /mnt/yy directory only can read.If client mount /root/hh/hh1 on /mnt/yy using nfs3, the /mnt/yy can write.
>>
>> nfs3 gets the filehandle of /root/hh/hh1 from rpc.mountd before really mounting, 
>> so that, nfs3 do the later process with the filehandle of /root/hh/hh1,
>> with the second exports entry.
>>  
>> But, nfs4 get the filehandle by LOOKUP through nfsd step by step, 
>> at first, LOOKUP "/" as the pseudo filesystem with an pseudo exports entry,
>> second, LOOKUP "/root/" also use the pseudo export entry, 
>> next, LOOKUP "/root/hh/" will get a new export entry
>> for "/root/" use a pseudo export entry, but at last LOOKUP "/root/hh/hh1",
>> nfsd uses the export entry for "/root/hh/" that isn't a pseudo entry entry.
>>
>> So that, nfsv3 client can write the directory, but nfsv4 client can't.
>>
>>> Who know how to solve this problem about nfs4? Thanks very much~
>>
>> Without change any codes of rpc.mountd and nfsd, there is a hacker method for it.
>> # chmod -x /root/hh/hh1
>> # chmod +t /root/hh/hh1
>> # setfattr -n "trusted.junction.nfs" -v "anything" /root/hh/hh1
>>
>> Umount the nfs and remount as nfsv4.
>>
>> Cc Bruce, Neil, Steve,
>>
>> Is it needed adding an xattr as "junction.nfs" for fixing this problem?
> 
> Maybe.  Or another trick you can use right now is to create a mountpoint
> there by mounting that directory on top of itself:
> 
> 	mount --bind /root/hh/hh1 /root/hh/hh1
> 
> However, I strongly discourage this kind of setup.
> 
> The problem is that it's very easy for an attacker to fake up a
> filehandle that points to a file under /root/hh while looking like it
> points to a file under /root/hh/hh1, and therefore get rw access to
> something outside /root/hh/hh1.  Turning on "subtree_check" will fix
> that problem, but can cause other problems.
> 
> It's much better, whenever possible, to use entirely different
> filesystems whenever you need to grant different access.

Hi linfei,

Can the two suggestions resolve your requirements?
I don't think the hacker method that change the code is sensible.

thanks,
Kinglong Mee
