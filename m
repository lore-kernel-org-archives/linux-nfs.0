Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48146 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752139AbcLHQNU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Dec 2016 11:13:20 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        "Trond Myklebust" <trondmy@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Concurrent `ls` takes out the thrash
Date: Thu,  8 Dec 2016 11:13:18 -0500
Message-Id: <3A6424D7-8207-4392-88C5-6CD3E1F65800@redhat.com>
In-Reply-To: <790E1295-EBBE-4059-9EEC-D2C9CD36EA20@redhat.com>
References: <C2A81CDB-ED8F-4D41-919F-3F92CBFF751B@redhat.com> <CEE29C1D-BB8F-4504-940D-43DE1FE63385@primarydata.com> <7DA8E9BE-7353-44D5-B982-B477CF7B0A57@redhat.com> <934FC075-4393-42AD-92A3-3BC3BE580699@redhat.com> <6C5DA8AC-9A42-45FA-892C-E9597A7F7AC9@primarydata.com> <EC88DF6D-5A78-499C-A6A8-A5D74083876F@redhat.com> <3C863AB4-D07A-494A-AD7B-87BF31496777@primarydata.com> <C3824A8A-17EF-465F-8267-55F0AD2C4239@redhat.com> <790E1295-EBBE-4059-9EEC-D2C9CD36EA20@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Benjamin Coddington" <bcodding@redhat.com>

Ehh.. I think it's kinda ugly, but this is what I came up with.

It works well, though, and handles everything I throw at it.  Its not as
simple as Christoph's suggestion to just go back to .iterate, which would
solve this in a simpler way.

Ben


8<---------------------------------------------------------------------------------------
