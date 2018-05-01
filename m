Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.133]:43410 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755434AbeEAPbM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 1 May 2018 11:31:12 -0400
Subject: Re: [PATCH 03/24] VFS: Introduce the structs and doc for a filesystem
 context [ver #7]
To: David Howells <dhowells@redhat.com>
Cc: viro@zeniv.linux.org.uk, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
References: <05034a85-013b-30b6-ce17-4c95d4cab195@infradead.org>
 <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
 <152414468332.23902.3065751107691714414.stgit@warthog.procyon.org.uk>
 <8450.1525184950@warthog.procyon.org.uk>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <96dacc1b-cffa-3aa2-71f5-70c8159c805e@infradead.org>
Date: Tue, 1 May 2018 08:31:00 -0700
MIME-Version: 1.0
In-Reply-To: <8450.1525184950@warthog.procyon.org.uk>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/01/2018 07:29 AM, David Howells wrote:
> Randy Dunlap <rdunlap@infradead.org> wrote:
> 
>>> + (2) Parse the options and attach them to the context.  Options may be passed
>>> +     individually from userspace.
>>
>> Does this say that step (2) can be multiple small steps?
> 
> Perhaps "phase (2)" would be a better name than "step (2)".  During (2),
> multiple argument-supplying calls may be made.

Ack.

>> How does step (2) know when userspace has completed sending individual
>> options?
> 
> Moving to phase (3) terminates phase (2).  This is triggered by userspace
> writing "x create" or "x reconfigure" to the fd as things stand.
> 
>>> + (6) Return an error message attached to the context.
>>
>> where/how is this done?
> 
> That got taken out and made general - which Linus then objected to.  I need to
> reinsert this and make it fscontext-specific as most people would really like
> to have it, the mount process being able to produce so many weird and
> wonderful errors.
> 
>>> +When the VFS creates this, it allocates ->fs_context_size bytes (as specified
>>> +by the file_system_type object) to hold both the fs_context struct and any
>>> +extra data required by the filesystem.  The fs_context struct is placed at the
>>> +beginning of this space.  Any extra space beyond that is for use by the
>>> +filesystem.  The filesystem should wrap the struct in its own, e.g.:
>>
>>                                                       in its own struct, e.g.:
> 
> How about "... The filesystem should wrap the struct in one of its own, e.g."?

OK.

>>> + (*) int security_fs_context_parse_option(struct fs_context *fc, char *opt);	
>>> +
>>> +     Called for each mount option.  The arguments are as for the
>>> +     ->parse_option() method.  An active LSM may reject one with an error, pass
>>> +     one over and return 0 or consume one and return 1.  If consumed, the
>>
>> What does "pass one over" mean?
> 
> How about:
> 
> 	An active LSM may return 0 to pass the option on to the filesystem, 1
> 	to cause the option to be discarded or an error to cause the option to
> 	be rejected.

Much better. Thanks.

-- 
~Randy
