Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:49177 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755868Ab2CJCDI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Mar 2012 21:03:08 -0500
Received: by vcqp1 with SMTP id p1so2020188vcq.19
        for <linux-nfs@vger.kernel.org>; Fri, 09 Mar 2012 18:03:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1331333515.2763.63.camel@lade.trondhjem.org>
References: <1331222633-2645-1-git-send-email-andros@netapp.com>
	<CADnza46qMiagwV39sJU7E4AKY0KMFyyHNTAis_+PO-0b8955Yg@mail.gmail.com>
	<1331333515.2763.63.camel@lade.trondhjem.org>
Date: Fri, 9 Mar 2012 18:03:06 -0800
Message-ID: <CADnza4545qkLnZRKcQ0ozacG7F5JK2bEYn2Lgs+C2zhZH_c0wg@mail.gmail.com>
Subject: Re: [PATCH 1/1] NFSv4.1 cleanup DS stateid error handling
From: Fred Isaman <faisaman4@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 9, 2012 at 2:51 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Fri, 2012-03-09 at 14:31 -0800, Fred Isaman wrote:
>> On Thu, Mar 8, 2012 at 8:03 AM,  <andros@netapp.com> wrote:
>> > From: Andy Adamson <andros@netapp.com>
>> >
>> > The error handler nfs4_state parameter is never NULL in the pNFS case as
>> > the open_context must carry an nfs_state.
>> >
>>
>>
>> Note Trond's argument is that with commit the state is avail for the
>> caller, so it need not be NULL.
>> But the caller filelayout_commit_done_cb() needs to be adjusted.
>> Currently commit to ds oopses
>> due to that.
>
> Are you sure? As far as I can see, filelayout_commit_pagelist _does_
> call nfs_init_commit(), which again sets the data->args.context.
> Later, filelayout_commit_done_cb calls filelayout_async_handle_error()
> using the data->args.context->state argument.
>
> How is that failing to provide a valid open state argument?
>
> --

Gah, sorry.  A rebase of some of my commit changes silently reverted
it to a NULL argument.  I withdraw my complaint.

Fred
