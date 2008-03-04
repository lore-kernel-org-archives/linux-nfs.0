From: "bc Wong" <bcwalrus@gmail.com>
Subject: [NFS] Choosing auth flavour in nfsmount.c
Date: Tue, 4 Mar 2008 14:04:39 -0800
Message-ID: <f88853200803041404m11a5e24eoc65fbb386a2cb41e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:51251 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755477AbYCDWEz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Mar 2008 17:04:55 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JWfFj-0005z8-QT
	for linux-nfs@vger.kernel.org; Wed, 05 Mar 2008 09:04:51 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I think nfsmount.c violates rfc2623 section 2.7:

   a NFS client SHOULD use the first flavor in the list that it
   supports, on the assumption that the best access is
   provided by the first flavor.

The code is on line 746:
                i = mountres->auth_flavors.auth_flavors_len;
                if (i <= 0)
                        goto noauth_flavors;

                flavor = mountres->auth_flavors.auth_flavors_val;
                while (--i >= 0) {
                        /* If no flavour requested, use first simple
                         * flavour that is offered.
                         */
                        if (! (data.flags & NFS_MOUNT_SECFLAVOUR) &&
                            (flavor[i] == AUTH_SYS ||
                             flavor[i] == AUTH_NONE)) {
                                data.pseudoflavor = flavor[i];
                                data.flags |= NFS_MOUNT_SECFLAVOUR;
                        }
                        if (flavor[i] == data.pseudoflavor)
                                yum = 1;
#ifdef NFS_MOUNT_DEBUG
                        printf(_("auth flavor %d: %d\n"), i, flavor[i]);
#endif
                }

If the server advertises AUTH_SYS and then AUTH_NONE,
the client will pick AUTH_NONE instead of AUTH_SYS.

I have a fix. What's the process of filing a bug? submitting
a patch? or getting involved with development?

Thanks,
bc

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

