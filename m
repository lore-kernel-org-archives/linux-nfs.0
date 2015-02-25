Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f176.google.com ([209.85.220.176]:51210 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866AbbBYO3v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Feb 2015 09:29:51 -0500
Received: by mail-vc0-f176.google.com with SMTP id la4so1429897vcb.7
        for <linux-nfs@vger.kernel.org>; Wed, 25 Feb 2015 06:29:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <54EDD559.4090804@cam.ac.uk>
References: <54EDD559.4090804@cam.ac.uk>
Date: Wed, 25 Feb 2015 09:29:50 -0500
Message-ID: <CAHQdGtRzW5+MYn5qDCrnqYb_F1+BpfZZ5JVEKYdUxmY7s7n8mw@mail.gmail.com>
Subject: Re: NFS4 client port for file delegations
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: drt24@cam.ac.uk
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 25, 2015 at 8:59 AM, Daniel Thomas <drt24@cam.ac.uk> wrote:
> We have a Linux NFS server (using ZFS) which supports NFS4. It uses
> fixed ports for everything and those ports are allowed through the
> firewall. We have a number of Linux clients which use this and other NFS
> servers, they have a DROP ALL for all all packets arriving on
> non-whitelisted ports.
>
> I think that file delegations might not be working due to callbacks not
> succeeding because the client port specified in SETCLIENTID by the
> client is blocked by the firewall.
>
> I have a couple of questions:
>
> How do I check whether file delegations are working properly? Munin
> graphs indicate 0 calls for some of the names which sound like they are
> to do with delegations such as delagreturn or delagpurge but is there
> some way of checking conclusively?
>
> How do I specify what client port to provide in SETCLIENTID, there
> should be some mount option? I can't find it. Or if it is a well defined
> number, what is it?
>
> Any pointers to answers?
>
