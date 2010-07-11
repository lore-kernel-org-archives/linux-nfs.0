Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:54796 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750873Ab0GKFDW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Jul 2010 01:03:22 -0400
In-Reply-To: <1278684348.2494.223.camel@moss-terrapins.epoch.ncsc.mil>
References: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
	<1278513086-23964-7-git-send-email-dpquigl@tycho.nsa.gov>
	<20100707170058.GD28815@fieldses.org> <alpine.LRH.2.00.1007080928180.14102@tundra.namei.org>
	<1278596363.2494.194.camel@moss-terrapins.epoch.ncsc.mil>
	<alpine.LRH.2.00.1007090834190.23354@tundra.namei.org> <1278684348.2494.223.camel@moss-terrapins.epoch.ncsc.mil>
From: Kyle Moffett <kyle@moffetthome.net>
Date: Sun, 11 Jul 2010 01:02:59 -0400
Message-ID: <AANLkTinUO-xqvQQINTzKLcXnljq-RaN5X6ulEAqvuf0d@mail.gmail.com>
Subject: Re: [PATCH 06/10] NFSv4: Add label recommended attribute and NFSv4
	flags
To: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: James Morris <jmorris@namei.org>, "J. Bruce Fields" <bfields@fieldses.org>,
        hch@infradead.org, viro@zeniv.linux.org.uk, casey@schaufler-ca.com,
        sds@tycho.nsa.gov, matthew.dodd@sparta.com, trond.myklebust@fys.uio.no,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jul 9, 2010 at 10:05, David P. Quigley <dpquigl@tycho.nsa.gov> wrote:
> On Fri, 2010-07-09 at 08:48 +1000, James Morris wrote:
>> Yes, but we should not unnecessarily limit the network protocol when
>> something is valid and possible in the local implementation (which is ~64k
>> under Linux).
>>
>> A security label include just about anything, e.g. an x509 certificate, or
>> a base64 encoded image.
>>
>> In the Linux implementation, if we can store a local label up to 64k, then
>> we should try and ensure that it can be conveyed via NFS.
>
> If you want that to be the case you need to make your case to Trond
> about that. I've already had this conversation before and he seems to
> think that a page is sufficient. Bruce also has concerns about not
> wanting these labels to require a high order allocation. Under memory
> pressure finding 16 contiguous pages for each label might be a problem.

I would argue that if somebody wants to stick a base64-encoded image
or an x509 certificate in their security labels then shipping the
whole thing across the wire every time somebody does an extended
"stat" is just stupid.  Think about how much overhead there would be
if you did an "ls -Z" of a directory with 100 files (64k * 100 ==
6.4MB!!!), where that data would previously have fit in no more than
10-20k TOTAL.

A better solution would be something along the lines of putting at
most a SHA512 sum in the label field and have a separate caching
communication protocol (either in-band or out-of-band) to pass the
fully-descriptive payload.

Even in local filesystems like ext3 we prefer to turn labels into
numbers, store the number with each inode, and then keep the labels
indexed in a separate datastructure.

Cheers,
Kyle Moffett
