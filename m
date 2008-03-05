From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] Choosing auth flavour in nfsmount.c
Date: Wed, 05 Mar 2008 11:59:09 -0500
Message-ID: <1204736349.1613.13.camel@heimdal.trondhjem.org>
References: <f88853200803041404m11a5e24eoc65fbb386a2cb41e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: bc Wong <bcwalrus@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:50854 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754214AbYCEQ7f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Mar 2008 11:59:35 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JWwxm-00011t-KD
	for linux-nfs@vger.kernel.org; Thu, 06 Mar 2008 03:59:30 +1100
In-Reply-To: <f88853200803041404m11a5e24eoc65fbb386a2cb41e-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-03-04 at 14:04 -0800, bc Wong wrote:
> I think nfsmount.c violates rfc2623 section 2.7:
> 
>    a NFS client SHOULD use the first flavor in the list that it
>    supports, on the assumption that the best access is
>    provided by the first flavor.
> 
> The code is on line 746:
>                 i = mountres->auth_flavors.auth_flavors_len;
>                 if (i <= 0)
>                         goto noauth_flavors;
> 
>                 flavor = mountres->auth_flavors.auth_flavors_val;
>                 while (--i >= 0) {
>                         /* If no flavour requested, use first simple
>                          * flavour that is offered.
>                          */
>                         if (! (data.flags & NFS_MOUNT_SECFLAVOUR) &&
>                             (flavor[i] == AUTH_SYS ||
>                              flavor[i] == AUTH_NONE)) {
>                                 data.pseudoflavor = flavor[i];
>                                 data.flags |= NFS_MOUNT_SECFLAVOUR;
>                         }
>                         if (flavor[i] == data.pseudoflavor)
>                                 yum = 1;
> #ifdef NFS_MOUNT_DEBUG
>                         printf(_("auth flavor %d: %d\n"), i, flavor[i]);
> #endif
>                 }
> 
> If the server advertises AUTH_SYS and then AUTH_NONE,
> the client will pick AUTH_NONE instead of AUTH_SYS.
> 
> I have a fix. What's the process of filing a bug? submitting
> a patch? or getting involved with development?

A patch should normally be sufficient, but please make sure that it
follows the guidelines in Documentation/SubmittingPatches (i.e. no major
style violations, a changelog entry at the top of the patch, and a
signed-off-by line).

Send all NFS client patches to me with a Cc to
linux-nfs-u79uwXL29TaiAVqoAR/hOK1cXZ9k6wlg@public.gmane.org

Thanks,
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

