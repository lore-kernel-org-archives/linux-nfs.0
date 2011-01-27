Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53716 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754266Ab1A0BZg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Jan 2011 20:25:36 -0500
In-Reply-To: <1296089830.25999.1.camel@heimdal.trondhjem.org>
References: <1295998215.6867.22.camel@heimdal.trondhjem.org>
	<21515.1296030022@jrobl>
	<1296072867.7127.26.camel@heimdal.trondhjem.org>
	<1296074585.7127.33.camel@heimdal.trondhjem.org>
	<AANLkTik2JJt4vcX8mMJmz+uwJU01vpMwF0UjQ+3QFAtp@mail.gmail.com>
	<1296086349.7127.55.camel@heimdal.trondhjem.org>
	<AANLkTim1-dwNjTpyCi5qBjCer5vgPo4qSNfK7Htd_vfL@mail.gmail.com>
	<1296089830.25999.1.camel@heimdal.trondhjem.org>
Date: Thu, 27 Jan 2011 12:25:35 +1100
Message-ID: <AANLkTim_JrZkD_D8HWXNr0qxjQ-=LKaAvzcH_w7A_T42@mail.gmail.com>
Subject: Re: 2.6.38-rc2... NFS sillyrename is broken...
From: Nick Piggin <npiggin@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "J. R. Okajima" <hooanon05@yahoo.co.jp>, linux-nfs@vger.kernel.org,
        Linux Filesystem Development <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jan 27, 2011 at 11:57 AM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Thu, 2011-01-27 at 11:44 +1100, Nick Piggin wrote:

>> But we could just check for d_count != 0 which means the parent has
>> to be valid as well (we have rename protection as well).
>
> That would certainly be less intrusive. Can you please propose a patch?

Yes I'll write something up today.
