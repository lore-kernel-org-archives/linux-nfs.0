Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59066 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751373AbcKYDrZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 24 Nov 2016 22:47:25 -0500
Date: Thu, 24 Nov 2016 22:47:06 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andreas Dilger <adilger@dilger.ca>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, fstests@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH xfstests] dirstress: Allow ESTALE as well as ENOENT
Message-ID: <20161125034706.GA20729@fieldses.org>
References: <20161123222054.GA7900@fieldses.org>
 <35420A4E-1698-4743-9523-CBF43F2A2DC6@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <35420A4E-1698-4743-9523-CBF43F2A2DC6@dilger.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 23, 2016 at 04:19:11PM -0700, Andreas Dilger wrote:
> On Nov 23, 2016, at 3:20 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > 
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > In the NFS case an attempt to chdir out of a removed directory could result
> > in ESTALE, and that should not cause the test to fail.
> > 
> > This was causing intermittent failures on generic/011 on NFS.
> > 
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> > src/dirstress.c | 12 ++++++++----
> > 1 file changed, 8 insertions(+), 4 deletions(-)
> > 
> > Sorry, who do xfstests patches go to?--b.
> 
> They are sent to fstests@vger.kernel.org

Thanks!

Might be worth something like this too?

--b.

commit 0d61e7b9779d
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Nov 24 22:41:26 2016 -0500

    Document fstests mailing list
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/README b/README
index d1f6788a17a3..0a6ac6ece5aa 100644
--- a/README
+++ b/README
@@ -248,3 +248,9 @@ Pass/failure:
     The recent pass/fail history is maintained in the file "check.log".
     The elapsed time for the most recent pass for each test is kept
     in "check.time".
+
+__________________
+SUBMITTING PATCHES
+__________________
+
+Send patches to the fstests mailing list at fstests@vger.kernel.org.
