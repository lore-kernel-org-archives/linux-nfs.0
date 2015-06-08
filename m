Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f43.google.com ([209.85.216.43]:36609 "EHLO
	mail-vn0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752136AbbFHMm1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2015 08:42:27 -0400
Received: by vnbg1 with SMTP id g1so17235046vnb.3
        for <linux-nfs@vger.kernel.org>; Mon, 08 Jun 2015 05:42:26 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 8 Jun 2015 08:42:26 -0400
Message-ID: <CAHQdGtQ6NSf2o+Tn=8f0HzECFV3WUOKcPODY-+-RmafUu6Mt7w@mail.gmail.com>
Subject: Re: [RFC PATCH V3 1/7] nfsd/sunrpc: add a new svc_serv_ops struct and
 move sv_shutdown into it
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Shirley Ma <shirley.ma@oracle.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 8, 2015 at 1:21 AM, Shirley Ma <shirley.ma@oracle.com> wrote:
> sunrpc: add a new svc_serv_ops struct and move sv_shutdown into it

The subject does not need to be duplicated in the body of the email.

> In later patches we'll need to abstract out more operations on a
> per-service level, besides sv_shutdown and sv_function.
>
> Declare a new svc_serv_ops struct to hold these operations, and move
> sv_shutdown into this struct.
>
> Author: Jeff Layton <jlayton@primarydata.com>

This should read

From: Jeff Layton <jlayton@primarydata.com>

and should be the first line in the body of your email so that 'git'
can pick it up automatically. See Documentation/SubmittingPatches

Trond
