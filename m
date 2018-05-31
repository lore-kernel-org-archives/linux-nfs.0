Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:32927 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750777AbeEaVxo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 31 May 2018 17:53:44 -0400
Subject: Re: nfs4_acl restricts copy_up in overlayfs
To: Miklos Szeredi <miklos@szeredi.hu>,
        Trond Myklebust <trondmy@hammerspace.com>
Cc: "bfields@fieldses.org" <bfields@fieldses.org>,
        "agruenba@redhat.com" <agruenba@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-unionfs@vger.kernel.org" <linux-unionfs@vger.kernel.org>
References: <f74fae81-d1bc-1c0e-7b41-69502bd7c489@suse.de>
 <f2af62fdf8a5bb185ec75cff118178d58b28ceb4.camel@hammerspace.com>
 <2cf94c6b-e819-79af-4ac9-3b19d26dc6d9@suse.de>
 <75266c983a03f6dbfd5d1a39c94fa6d56a1a8a22.camel@hammerspace.com>
 <a0617bb0-b7a5-fab2-c72c-595e005bd8f7@suse.de>
 <20180531004554.GA29116@fieldses.org>
 <CAJfpegtoLpwo6aA9=uF72UDaKvv_Q3bUbv778VwnSDa72yO9Mw@mail.gmail.com>
 <128c74cb1507d7eab36ac8d32182dbbc7d3f9f88.camel@hammerspace.com>
 <CAJfpeguK9rmXK4F7wkE8of7gwDTV_KbM4yWAW8iGJ0RvOMH0-g@mail.gmail.com>
 <e692f5a6f612660ad0a64e083ed7a1398629aa6d.camel@hammerspace.com>
 <CAJfpegsW7CwZYJf_EH80aaYotMMBDk1BjR_RA6dz8e=Y3-ox5w@mail.gmail.com>
From: Goldwyn Rodrigues <rgoldwyn@suse.de>
Message-ID: <d6fab628-6fd1-de33-2ca4-d82917205ce7@suse.de>
Date: Thu, 31 May 2018 16:53:38 -0500
MIME-Version: 1.0
In-Reply-To: <CAJfpegsW7CwZYJf_EH80aaYotMMBDk1BjR_RA6dz8e=Y3-ox5w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/31/2018 08:30 AM, Miklos Szeredi wrote:
> On Thu, May 31, 2018 at 3:10 PM, Trond Myklebust
> <trondmy@hammerspace.com> wrote:

>>>
>>> I understand.  Ignoring nfs4_acl in overlayfs will have the same
>>> result as adding noacl to the underlying NFS mount.

Adding noacl in NFS client mount has no affect to nfs4_acl. Only if you
add noacl in the underlying filesystem of exported directory in the
server does the nfs4_acl go away.

-- 
Goldwyn
