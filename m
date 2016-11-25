Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36380 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752257AbcKYLfO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 25 Nov 2016 06:35:14 -0500
Date: Fri, 25 Nov 2016 19:35:11 +0800
From: Eryu Guan <eguan@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Andreas Dilger <adilger@dilger.ca>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>, fstests@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH xfstests] dirstress: Allow ESTALE as well as ENOENT
Message-ID: <20161125113511.GI4609@eguan.usersys.redhat.com>
References: <20161123222054.GA7900@fieldses.org>
 <35420A4E-1698-4743-9523-CBF43F2A2DC6@dilger.ca>
 <20161125034706.GA20729@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20161125034706.GA20729@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

On Thu, Nov 24, 2016 at 10:47:06PM -0500, J. Bruce Fields wrote:
> On Wed, Nov 23, 2016 at 04:19:11PM -0700, Andreas Dilger wrote:
> > On Nov 23, 2016, at 3:20 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > > 
> > > From: "J. Bruce Fields" <bfields@redhat.com>
> > > 
> > > In the NFS case an attempt to chdir out of a removed directory could result
> > > in ESTALE, and that should not cause the test to fail.
> > > 
> > > This was causing intermittent failures on generic/011 on NFS.
> > > 
> > > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > > ---
> > > src/dirstress.c | 12 ++++++++----
> > > 1 file changed, 8 insertions(+), 4 deletions(-)
> > > 
> > > Sorry, who do xfstests patches go to?--b.
> > 
> > They are sent to fstests@vger.kernel.org
> 
> Thanks!
> 
> Might be worth something like this too?

This looks fine to me. Can you please resend as a formal patch? Also the
patch to fix dirstress.c.

Thanks,
Eryu
