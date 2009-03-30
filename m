From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v2 07/47] nfsd41: define nfs41 error codes
Date: Mon, 30 Mar 2009 16:08:59 -0400
Message-ID: <20090330200859.GJ31237@fieldses.org>
References: <49CDDFC2.4070402@panasas.com> <1238229075-9010-1-git-send-email-bhalevy@panasas.com> <20090330181640.GD31237@fieldses.org> <49D1249B.4050701@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:57628 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752117AbZC3UJB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2009 16:09:01 -0400
In-Reply-To: <49D1249B.4050701@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 30, 2009 at 10:59:23PM +0300, Benny Halevy wrote:
> On Mar. 30, 2009, 21:16 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > On Sat, Mar 28, 2009 at 11:31:15AM +0300, Benny Halevy wrote:
> >> From: Marc Eshel <eshel@almaden.ibm.com>
> >>
> >> Define all error code present in
> >> http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-29.
> >>
> >> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> >> [nfsd41: clean up error code definitions]
> >> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> >> ---
> >>  include/linux/nfs.h       |    2 --
> >>  include/linux/nfsd/nfsd.h |   43 ++++++++++++++++++++++++++++++++++++++++++-
> >>  2 files changed, 42 insertions(+), 3 deletions(-)
> >>
> >> diff --git a/include/linux/nfs.h b/include/linux/nfs.h
> >> index 1510a64..214d499 100644
> >> --- a/include/linux/nfs.h
> >> +++ b/include/linux/nfs.h
> >> @@ -109,8 +109,6 @@
> >>  	NFSERR_FILE_OPEN = 10046,      /*       v4 */
> >>  	NFSERR_ADMIN_REVOKED = 10047,  /*       v4 */
> >>  	NFSERR_CB_PATH_DOWN = 10048,   /*       v4 */
> >> -
> >> -	NFSERR_REPLAY_ME = 11001,	/* linux internal */
> > 
> > This renders "[PATCH v2 05/47] nfsd41: change NFSERR_REPLAY_ME" moot;
> > just drop that previous patch.
> 
> I see you already pulled the former patch into for-2.6.30...

Yes.  Should be fixed now, though.

--b.
