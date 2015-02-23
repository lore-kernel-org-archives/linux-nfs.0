Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out03.mta.xmission.com ([166.70.13.233]:58457 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752284AbbBWSuI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Feb 2015 13:50:08 -0500
From: ebiederm@xmission.com (Eric W. Biederman)
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Wang YanQing <udknight@gmail.com>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
References: <20150223154419.GA2542@mwanda>
	<87385w1rmd.fsf@x220.int.ebiederm.org> <20150223180326.GC5116@mwanda>
Date: Mon, 23 Feb 2015 12:46:37 -0600
In-Reply-To: <20150223180326.GC5116@mwanda> (Dan Carpenter's message of "Mon,
	23 Feb 2015 21:03:27 +0300")
Message-ID: <87fv9wzcs2.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [patch] groups: integer underflow in groups_alloc()
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dan Carpenter <dan.carpenter@oracle.com> writes:

> On Mon, Feb 23, 2015 at 11:10:02AM -0600, Eric W. Biederman wrote:
>> Dan Carpenter <dan.carpenter@oracle.com> writes:
>> 
>> > This is called from rsc_parse() with a use controlled value.  Say for
>> > example that "gidsetsize" is negative, then we could end up allocating
>> > less than sizeof(struct group_info) leading to memory corruption.
>> 
>> Right now it is the responsibility of the caller of groups_alloc to make
>> certain that gidsetsize is a valid value, and the callers of
>> groups_alloc who know what they are doing already validate this value.
>> 
>> Either the pattern of caller validates the messages needs to continue,
>> or groups_alloc needs to be changed and all of the callers need to be
>> updated.
>> 
>> Changing groups_alloc for one particular caller is just going to cause
>> maintenance problems.
>> 
>
> This only affects NFS so let's hear from them if this limit is correct
> and decide from there.

The bug may be nfs specific bug changing groups_alloc does not only
affect nfs.

NGROUPS_MAX is the maxmimum number of groups the linux kernel supports
so NGROUPS_MAX may be high but it is certainly not wrong.

Your patch takes the wrong approach, creates code that is an
inconsistent mess and is thus wrong.  As setgroups is code that is
called every day I don't think only paying attention to NFS when talking 
how to change this is in any way appropriate, unless you propose an NFS
specific fix (which you clearly did not).

Eric
