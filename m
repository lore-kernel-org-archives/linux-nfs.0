Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 997A5C77B73
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Apr 2023 02:20:53 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229510AbjDQCUw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 16 Apr 2023 22:20:52 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:46182 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229565AbjDQCUv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 16 Apr 2023 22:20:51 -0400
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.220.29])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 3EC1826B0
        for <linux-nfs@vger.kernel.org>; Sun, 16 Apr 2023 19:20:22 -0700 (PDT)
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by smtp-out2.suse.de (Postfix) with ESMTPS id DBA5E1F86A;
        Mon, 17 Apr 2023 02:20:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1681698020; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=258a0T4SiHUX4NVrg8OXCJ8IFAzNzC7bmB/Dyfoub6s=;
        b=m1x1hwEohCQe1qTdEbd0UG6GuQ0fYzivp30dc18UF60j3BXfGf+oSdWpekClOw9LsF04WB
        K92Q0FM3C526DrcaOCERRYgNKSUj98vDQ9pY2swruWX9jxl4tjsD7VOM5L+MZJfzx0mQiT
        CHjsavcztFZQlkSg2vhhibDIIgKR1Vo=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1681698020;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=258a0T4SiHUX4NVrg8OXCJ8IFAzNzC7bmB/Dyfoub6s=;
        b=mVlweAHv2DPdFUP9UffvByPAupz5s53Ba4721Mcz1lcwKplCiIa9NvjURdY5R7AdZLOISP
        jMSjRNr22ZDMR/Aw==
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by imap2.suse-dmz.suse.de (Postfix) with ESMTPS id D04FD13319;
        Mon, 17 Apr 2023 02:20:18 +0000 (UTC)
Received: from dovecot-director2.suse.de ([192.168.254.65])
        by imap2.suse-dmz.suse.de with ESMTPSA
        id 8213IeKsPGThMQAAMHmgww
        (envelope-from <neilb@suse.de>); Mon, 17 Apr 2023 02:20:18 +0000
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
From:   "NeilBrown" <neilb@suse.de>
To:     "Wang Yugui" <wangyugui@e16-tech.com>
Cc:     "Steve Dickson" <steved@redhat.com>, "Petr Vorel" <pvorel@suse.cz>,
        "linux-nfs" <linux-nfs@vger.kernel.org>,
        "Dave Jones" <davej@codemonkey.org.uk>, bfields@redhat.com
Subject: Re: [PATCH nfs-utils] mountd: don't advertise krb5 for v4root when
 not configured.
In-reply-to: <20230417100511.9131.409509F4@e16-tech.com>
References: <168169080542.24821.1095959058130927513@noble.neil.brown.name>,
 <20230417100511.9131.409509F4@e16-tech.com>
Date:   Mon, 17 Apr 2023 12:20:15 +1000
Message-id: <168169801568.24821.12909751358635990715@noble.neil.brown.name>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, 17 Apr 2023, Wang Yugui wrote:
> Hi,
>=20
> >=20
> > If /etc/krb5.keytab does not exist, then krb5 cannot work, so
> > advertising it as an option for v4root is pointless.
> > Since linux commit 676e4ebd5f2c ("NFSD: SECINFO doesn't handle
> > unsupported pseudoflavors correctly") this can result in an unhelpful
> > warning if the krb5 code is not built, or built as a module which is not
> > installed.
> >=20
> > [  161.668635] NFS: SECINFO: security flavor 390003 is not supported
> > [  161.668655] NFS: SECINFO: security flavor 390004 is not supported
> > [  161.668670] NFS: SECINFO: security flavor 390005 is not supported
> >=20
> > So avoid advertising krb5 security options when krb5.keytab cannot be
> > found.
> >=20
> > Link: https://lore.kernel.org/linux-nfs/20170104190327.v3wbpcbqtfa5jy7d@c=
odemonkey.org.uk/
> > Signed-off-by: NeilBrown <neilb@suse.de>
> > ---
> >  support/export/v4root.c         |  2 ++
> >  support/include/pseudoflavors.h |  1 +
> >  support/nfs/exports.c           | 14 +++++++-------
> >  3 files changed, 10 insertions(+), 7 deletions(-)
> >=20
> > diff --git a/support/export/v4root.c b/support/export/v4root.c
> > index fbb0ad5f5b81..3e049582d7c1 100644
> > --- a/support/export/v4root.c
> > +++ b/support/export/v4root.c
> > @@ -66,6 +66,8 @@ set_pseudofs_security(struct exportent *pseudo)
> > =20
> >  		if (!flav->fnum)
> >  			continue;
> > +		if (flav->need_krb5 && !access("/etc/krb5.keytab", F_OK))
> > +			continue;
>=20
> Could we replace "/etc/krb5.keytab" with krb5_kt_default_name()?

Maybe?  Why would we want to?

The presence of /etc/krb5.keytab is what we already use in a couple of
systemd unit files to determine if krb5 is configured.  Why not just use
the same here?

NeilBrown
