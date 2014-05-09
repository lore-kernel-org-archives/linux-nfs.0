Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f171.google.com ([209.85.220.171]:43451 "EHLO
	mail-vc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbaEIA4Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 May 2014 20:56:24 -0400
Received: by mail-vc0-f171.google.com with SMTP id lc6so4321775vcb.2
        for <linux-nfs@vger.kernel.org>; Thu, 08 May 2014 17:56:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140506234136.GU18281@fieldses.org>
References: <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-6-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-7-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-8-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-9-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-10-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-11-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-12-git-send-email-trond.myklebust@primarydata.com>
	<20140506234136.GU18281@fieldses.org>
Date: Thu, 8 May 2014 20:56:23 -0400
Message-ID: <CAHQdGtSipKUJ40xorFAh37zyqBpBAYiZb7vo_NsLDAd6GSC+sA@mail.gmail.com>
Subject: Re: [PATCH 11/70] NFSd: Ensure delegation setup is safe w.r.t. break_lease()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 6, 2014 at 7:41 PM, Bruce Fields <bfields@fieldses.org> wrote:
> On Fri, Apr 18, 2014 at 02:44:05PM -0400, Trond Myklebust wrote:
>> Ensure that we add/remove the dl_perfile under the inode->i_lock
>
> Looks like maybe this addresses my question on the previous patch--in
> which case it should really be merged with the previous patch for
> bisectability?
>

We could, but the client_mutex will continue to mask any conflicts. In
the case where it doesn't, it would be because the existing code is
already borken.

It really is quite non-trivial to work out all the relationships that
are at work here, and to order the patches in a sane way. I'm quite
open to suggestions for improvements, but when in doubt, I'm relying
on the 'big umbrella' being up there until it is removed...


-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
