Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:35431 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911AbbJ1Tah convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Oct 2015 15:30:37 -0400
Received: by oifu63 with SMTP id u63so11055723oif.2
        for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2015 12:30:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <216A83C3-D724-49C7-A64B-3471CF981AA3@oracle.com>
References: <216A83C3-D724-49C7-A64B-3471CF981AA3@oracle.com>
Date: Wed, 28 Oct 2015 15:30:36 -0400
Message-ID: <CAHQdGtREX8ZPw9eVaXpxaPSjmfjQvQpXcxS5DnOdjgq=zfthSg@mail.gmail.com>
Subject: Re: GSSD warning with proto=rdma
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 28, 2015 at 2:56 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> Hi-
>
> I’m beginning to try Kerberos with NFS/RDMA. I get this complaint
> from GSSD:
>
> Oct 28 13:10:02 manet rpc.gssd[2549]: WARNING: unrecognized
> protocol, 'rdma', requested for connection to server
> klimt-ib.1015granger.net for user with uid 0
>
> Should I change the kernel NFS client to tell GSSD it’s using
> TCP, or should I change GSSD to recognize RDMA as another form
> of TCP?
>

gssd expects to be able to connect to the IP address that we pass in
the upcall. If we can guarantee that IP address can always be resolved
in a TCP connection attempt, then let's lie, and call it TCP.

Cheers
  Trond
