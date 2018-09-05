Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua1-f49.google.com ([209.85.222.49]:38626 "EHLO
        mail-ua1-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726335AbeIEURZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Sep 2018 16:17:25 -0400
Received: by mail-ua1-f49.google.com with SMTP id o11-v6so6187814uak.5
        for <linux-nfs@vger.kernel.org>; Wed, 05 Sep 2018 08:46:39 -0700 (PDT)
MIME-Version: 1.0
References: <87r2i8vq10.fsf@notabene.neil.brown.name> <f7f84aced6ae709b1c66e1475e8d79927fa29132.camel@hammerspace.com>
 <87o9dcvmk6.fsf@notabene.neil.brown.name> <CAN-5tyG0DXosk0RUCM6E+pj-EmMWW5tuKfPg4HJChp9snvcQAQ@mail.gmail.com>
 <f700a6d48218533ed2a3ca3a23c06c9cd40cf3c8.camel@hammerspace.com>
In-Reply-To: <f700a6d48218533ed2a3ca3a23c06c9cd40cf3c8.camel@hammerspace.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 5 Sep 2018 11:46:27 -0400
Message-ID: <CAN-5tyEa0cYYiSkwncw=662393N65z=Fy6SyzkiEeo4jkpUnhw@mail.gmail.com>
Subject: Re: NFSv4.1 session reset needs to update ->rsize and ->wsize - how???
To: Trond Myklebust <trondmy@hammerspace.com>
Cc: NeilBrown <neilb@suse.com>, linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 5, 2018 at 11:12 AM Trond Myklebust <trondmy@hammerspace.com> wrote:
>
> On Wed, 2018-09-05 at 09:44 -0400, Olga Kornievskaia wrote:
> > commit 033853325fe3bdc70819a8b97915bd3bca41d3af
> > Author: Olga Kornievskaia <kolga@netapp.com>
> > Date:   Wed Mar 8 14:39:15 2017 -0500
> >
> >     NFSv4.1 respect server's max size in CREATE_SESSION
> >
> >     Currently client doesn't respect max sizes server returns in
> > CREATE_SESSION.
> >     nfs4_session_set_rwsize() gets called and server->rsize, server-
> > >wsize are 0
> >     so they never get set to the sizes returned by the server.
> >
> >     Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> >     Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> >
>
> Olga, I'm confused by that patch. It appears to assume that we should
> be using the CREATE_SESSION, request/response limits as default values
> instead of as limits?
>
> AFAICS, the real problem there is that nfs4_server_common_setup() is
> calling nfs4_session_set_rwsize() before we actually set the r/wsize in
> the call to nfs_probe_fsinfo(). No?

I didn't know that nfs_probe_fsinfo() set the server->r/wsize. I
thought it was only set in nfs4_session_set_rwsize() to the values
from the session attributes.
