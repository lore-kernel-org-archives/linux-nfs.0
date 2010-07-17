Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57326 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759483Ab0GQAJq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Jul 2010 20:09:46 -0400
In-Reply-To: <1278945396.5221.14.camel@moss-pluto.epoch.ncsc.mil>
References: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
	<1278513086-23964-7-git-send-email-dpquigl@tycho.nsa.gov>
	<20100707170058.GD28815@fieldses.org> <alpine.LRH.2.00.1007080928180.14102@tundra.namei.org>
	<1278596363.2494.194.camel@moss-terrapins.epoch.ncsc.mil>
	<alpine.LRH.2.00.1007090834190.23354@tundra.namei.org> <1278684348.2494.223.camel@moss-terrapins.epoch.ncsc.mil>
	<AANLkTinUO-xqvQQINTzKLcXnljq-RaN5X6ulEAqvuf0d@mail.gmail.com>
	<4C3952D6.7040608@schaufler-ca.com> <1278945396.5221.14.camel@moss-pluto.epoch.ncsc.mil>
From: Kyle Moffett <kyle@moffetthome.net>
Date: Fri, 16 Jul 2010 20:09:23 -0400
Message-ID: <AANLkTimBkFfkNmh8Rn3IH1ktGixUxQY8LPP56_joA93S@mail.gmail.com>
Subject: Re: [PATCH 06/10] NFSv4: Add label recommended attribute and NFSv4
	flags
To: Stephen Smalley <sds@tycho.nsa.gov>
Cc: Casey Schaufler <casey@schaufler-ca.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        James Morris <jmorris@namei.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, hch@infradead.org,
        viro@zeniv.linux.org.uk, matthew.dodd@sparta.com,
        trond.myklebust@fys.uio.no, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-security-module@vger.kernel.org,
        selinux@tycho.nsa.gov, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Jul 12, 2010 at 10:36, Stephen Smalley <sds@tycho.nsa.gov> wrote:
> On Sat, 2010-07-10 at 22:12 -0700, Casey Schaufler wrote:
>> Kyle Moffett wrote:
>> > ...
>> > Even in local filesystems like ext3 we prefer to turn labels into
>> > numbers, store the number with each inode, and then keep the labels
>> > indexed in a separate datastructure.
>> >
>>
>> I don't know what system you're talking about, but that notion
>> was pretty well dispelled in the late 1980's, after the SystemV/MLS
>> and SecureWare examples.
>
> SELinux did that too before switching to using xattrs for label storage.
> Persistent security identifier (PSID) associated with each inode (either
> stored directly in the inode in the original kernel patches or
> associated through a separate mapping in the LSM-based implementation),
> with a mapping from PSID to context stored in a mapping within each
> filesystem.  Allowed you to keep the labels with the volume but avoided
> storing the same label multiple times.
>
> The xattr based implementation can sometimes share storage but only when
> the xattr is stored in the additional block (not when they are stored
> inline) and only if all of the xattrs on the file are identical.

Hmm, for some reason I was still thinking that we stored an encoded
form of the label even in xattrs.  Whoops!

On the other hand, I guess it should be noted that the "common" case
of an SELinux label is the inline storage case, labels are on average
no more than ~40 bytes:
  system_u:object_r:sysadm_homedir_t:s0

In filesystems that are space optimized (like squashfs), we still
prefer to pack xattrs, symlinks, and even file permissions as tightly
as possible through table lookups of various forms.  Heck, the
read-only squashfs only stores a single empty-directory inode and
references it wherever needed.

On the other hand, if you're doing something completely silly with 64k
labels then any hope of inline storage went out the window along with
any space savings from nifty FS optimizations like de-duplication or
tail-packing.

Cheers,
Kyle Moffett
