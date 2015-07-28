Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:34896 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbbG1L7S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jul 2015 07:59:18 -0400
Received: by obbop1 with SMTP id op1so82049965obb.2
        for <linux-nfs@vger.kernel.org>; Tue, 28 Jul 2015 04:59:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55B763CE.2040408@gmail.com>
References: <55B763CE.2040408@gmail.com>
Date: Tue, 28 Jul 2015 07:59:17 -0400
Message-ID: <CAHQdGtRbHyQ-1o-z5=0-dN7EC-CdH4y14Ju8t+aOWrfnAETezw@mail.gmail.com>
Subject: Re: [PATCH 5/5] NFS: Let opened is optional in _nfs4_do_open
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 28, 2015 at 7:13 AM, Kinglong Mee <kinglongmee@gmail.com> wrote:
>
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>

Please add a changelog explaining why we need to apply this patch.
