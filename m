Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f174.google.com ([209.85.214.174]:61950 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752720Ab2HBVg2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Aug 2012 17:36:28 -0400
Received: by obbuo13 with SMTP id uo13so9704obb.19
        for <linux-nfs@vger.kernel.org>; Thu, 02 Aug 2012 14:36:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJ75kXb=GpKFkOQRiMqqpoH6+wEOP4sh5spS4Y8y-k__mbE6kA@mail.gmail.com>
References: <CAJ75kXZb2_MGOrxG6JRyGEKdHm+t_yUk755DpqTvpdyVZ4TFzg@mail.gmail.com>
 <1343687301.28035.11.camel@lade.trondhjem.org> <CAJ75kXb=GpKFkOQRiMqqpoH6+wEOP4sh5spS4Y8y-k__mbE6kA@mail.gmail.com>
From: William Dauchy <wdauchy@gmail.com>
Date: Thu, 2 Aug 2012 23:28:36 +0200
Message-ID: <CAJ75kXYqHpLXUqW3FkVsXu3=pybaBaTZ0AGfRG8ur8OcwGKX-w@mail.gmail.com>
Subject: Re: wait_for_key_construction oops
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        David Howells <dhowells@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 31, 2012 at 10:07 AM, William Dauchy <wdauchy@gmail.com> wrote:
> I guess that the fixes from David Howells (a427b9e) are related to my
> oops I mentioned; particularly the point 4 in his commit.

Seems not because I'm also still getting this oops on wait_for_key_construction
-- 
William
