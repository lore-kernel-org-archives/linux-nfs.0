Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:37067 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754830Ab2BBK6I convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Feb 2012 05:58:08 -0500
Received: by werb13 with SMTP id b13so1700756wer.19
        for <linux-nfs@vger.kernel.org>; Thu, 02 Feb 2012 02:58:06 -0800 (PST)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <4F2A2F9E.6030908@steve-ss.com>
References: <4F2A2F9E.6030908@steve-ss.com>
Date: Thu, 2 Feb 2012 11:58:06 +0100
Message-ID: <CAGue13owEdBsr+anLKrbW931QZHYC7RbwiSH_7WjBb5aXw4JJQ@mail.gmail.com>
Subject: Re: where can I ask user qns about nfs4?
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: steve <steve@steve-ss.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve,

On Thu, Feb 2, 2012 at 7:39 AM, steve <steve@steve-ss.com> wrote:
> I want to ask a question about nfs4 keytabs and Samba 4. I've tried asking
> here, on the Samba 4 list and on the openSUSE list (which is my Linux
> distribution) but they refer me to an nfs list. I see that this list is only
> for nfs devs.
>
> I don't want to waste your time here but my question is just this:
>
> My nfs4 server has a service principal nfs/server.domain.name
>
> I already use nfs4 to serve my Linux clients. I'm going to kerberize it. My
> clients already have machine and host principals. What else do they need?
>
> 1. nfs/client.domain.name
> 2. nfs/server.domain/name
> 3. neither
> 4. both
>

We run kerberized NFS.

our keytab contains:

on server;
  nfs/server.domain

on client:
  nfs/client.domain

and, of course, you need a consistent  idmap configuration.

Tigran.

> The Google doco is contradictory and confusing to say the least. If you
> can't help, could you point me in the right direction?
>
> Thanks so much fr your time,
> Steve
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
