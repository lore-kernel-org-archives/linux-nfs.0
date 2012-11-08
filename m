Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36011 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755403Ab2KHMTF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Nov 2012 07:19:05 -0500
Date: Thu, 8 Nov 2012 07:19:01 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andrey Borzenkov <arvidjaar@gmail.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Effective process GID is ignored when client creates file on NFS
Message-ID: <20121108121901.GA22735@fieldses.org>
References: <CAA91j0VBWhT58iyNDTMXVnMU8skJTEwHyezD_HyhmaqW5+pt3w@mail.gmail.com>
 <20121107191336.GE7421@fieldses.org>
 <20121107232801.27afef92@opensuse.site>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9092AE579@SACEXCMBX04-PRD.hq.netapp.com>
 <20121108071250.78c36ab3@opensuse.site>
 <CAA91j0UthFpt3TeJWUV4YAMyKdEKhYGZrK4j8odPd6td_s-g9w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAA91j0UthFpt3TeJWUV4YAMyKdEKhYGZrK4j8odPd6td_s-g9w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 08, 2012 at 10:43:04AM +0400, Andrey Borzenkov wrote:
> OK this gave me idea. So the problem is indeed anon=0. If I reexport
> the same filesystems with root=... option, files are created with
> correct group ownership. I have to think about it, but on the first
> glance NetApp behavior is correct. As root= option is missing it maps
> root to anonymous user, and as anon=0 is present, this anonymous user
> is root. What do standards say about group ownership in this case?

As far as the NFS specs are concerned this sort of thing is up to the
implementation.

The behavior you describe sounds reasonable to me, and is similar to
what the Linux server would do, for example.

--b.
