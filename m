Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35388 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752771AbdARKQk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Jan 2017 05:16:40 -0500
Received: by mail-pf0-f195.google.com with SMTP id f144so857565pfa.2
        for <linux-nfs@vger.kernel.org>; Wed, 18 Jan 2017 02:16:40 -0800 (PST)
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: Re: [PATCH] exportfs: Make sure pass all valid export flags to nfsd
To: "J. Bruce Fields" <bfields@fieldses.org>
References: <c0826298-545e-64a3-b6bb-86413bf9eb39@gmail.com>
 <20170106210531.GB31401@fieldses.org>
 <49b7be0a-548a-cff1-8f09-613cd5c63141@gmail.com>
 <20170111141650.GA18977@fieldses.org>
 <fdea0dfa-14f6-a29b-4001-549f0a40601d@gmail.com>
 <20170116165410.GB2953@fieldses.org>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>,
        Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <c3855556-6e9d-8bd2-0635-e5c9af32b6f5@gmail.com>
Date: Wed, 18 Jan 2017 18:16:32 +0800
MIME-Version: 1.0
In-Reply-To: <20170116165410.GB2953@fieldses.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 1/17/2017 00:54, J. Bruce Fields wrote:
> On Sun, Jan 15, 2017 at 03:43:21PM +0800, Kinglong Mee wrote:
>> On 1/11/2017 22:16, J. Bruce Fields wrote:
>>> On Sat, Jan 07, 2017 at 07:57:28PM +0800, Kinglong Mee wrote:
>>>> On 1/7/2017 05:05, J. Bruce Fields wrote:
>>>>> On Sat, Dec 31, 2016 at 09:05:11PM +0800, Kinglong Mee wrote:
>>>>>> test_export pass a export flags only marks NFSEXP_FSID,
>>>>>> nfsd may want other flags for export checking.
>>>>>
>>>>> Why?  What problem does this fix?
>>>>
>>>> When testing the patch "NFSD: Only support readonly export for
>>>> !fsync and readonly filesystem", I found exportfs don't pass 
>>>> all valid export flags to nfsd. So, make this patch.
>>>
>>> This function is meant to test whether a filesystem supports nfs export
>>> or not.  It doesn't need the full set of export flags.  Off the top of
>>> my head I can't see reason this would cause problems, but I'm not
>>> convinced it's safe, either.  (New nfs-utils against old kernels might
>>> be a case to check, e.g. to see how unsupported flags are handled.)
>>
>> There are two cases that passing the flags to nfsd, 
>> 1, exportfs checks the export entry, only NFSEXP_FSID without this patch,
>> 2, mountd pass the validate export entry, all validate export flags.
>>
>> When the new nfs-utils against old kernels,
>> user specifies an unsupported flags(Not NFSEXP_FSID),
>> exportfs doesn't warning that unsupported flags (without test),
>> mountd doesn't get the export entry for the flags.
>>
>> If exportfs warning the unsupported flags, user can modify it and
>> do the right export.
>> Do I have an exact understanding?
> 
> OK, so when somebody specifies unsupported flags, the failures is silent
> and client mounts just fail.  It would be better to warn when exportfs
> runs.
> 
> I agree that that would be helpful.  Have you tested those cases?  (new
> nfs-utils, old kernel).

I test the latest nfs-utils with centos7 (3.10.0-514.2.2.el7.x86_64) which
not support "security_label" flag. nfsd runs without any errors.

# cat /etc/exports
/nfs	*(rw,insecure,no_root_squash,no_subtree_check,fsid=0,pnfs,security_label)

# cat /var/lib/nfs/etab 
/nfs	*(rw,sync,wdelay,hide,nocrossmnt,insecure,no_root_squash,
no_all_squash,no_subtree_check,secure_locks,acl,security_label,pnfs,fsid=0,
anonuid=65534,anongid=65534,sec=sys,insecure,no_root_squash,no_all_squash)

# cat /proc/fs/nfsd/exports 
# Version 1.1
# Path Client(Flags) # IPs
/nfs	*(rw,insecure,no_root_squash,sync,wdelay,no_subtree_check,pnfs,fsid=0,
uuid=767ef2f3:a8b34db9:b372b254:8cae731a,sec=1)

I add trace log for export flags in svc_export as,
svc_export_parse: exflags 0x224a2         "a" contains NFSEXP_SECURITY_LABEL
fh_verify: exflags 0x224a2       "a" contains NFSEXP_SECURITY_LABEL         

if I remove "security_label" from /etc/exports, 
svc_export_parse: exflags 0x22422
fh_verify: exflags 0x22422

nfsd has the right export flags (include unsupported flags), but
doesn't parse the unsupported flags, so that, runs without any errors.

> 
> It would be worth looking at validate_export() to see how it could
> improve error messages in this case.  Currently it will say only:
> 
> 	/example/export does not support NFS export
> 
> or
> 
> 	/example/export requires fsid= for export
> 
> With your patch (forgive me if I misremember), I believe those are still
> the only error messages, so it will be confusing if, for example, you
> get
> 
> 	/example/export does not support NFS export
> 
> when the real problem is that an export flag is unsupported.  (But maybe
> you had kernel messages to help there, I don't remember.)

Yes, those error messages are shortage.
I will check them and try to make them better.

thanks,
Kinglong Mee
