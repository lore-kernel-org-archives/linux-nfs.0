Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:45715 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754377Ab1EWOWY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2011 10:22:24 -0400
Received: by gyd10 with SMTP id 10so2094647gyd.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 May 2011 07:22:23 -0700 (PDT)
In-Reply-To: <4DD855CD.3060901@panasas.com>
References: <4DD84E8E.5040508@panasas.com>
	<4DD855CD.3060901@panasas.com>
Date: Mon, 23 May 2011 10:22:23 -0400
Message-ID: <BANLkTim30-pDMWTyirSh4uT-C9zJK9XyJg@mail.gmail.com>
Subject: Re: Smack on the head: Questions about pnfs write path
From: Fred Isaman <iisaman@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, May 21, 2011 at 8:16 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 05/22/2011 02:45 AM, Boaz Harrosh wrote:
>>
>> Fred git blame points to you:
>>
>> What was the meaning of the below code:
>>
>
> OK Smack *ME* on the head
>
> A layout driver must have a .pg_test function else
> that's what happens. pNFS only for a single page.
> I'd say it should be opposite no?
>

Right now, a driver with no pg_test function erroneously misses the
pnfs_update_layout call in multi-page io.  I'll send a patch to fix
that shortly.

Fred
