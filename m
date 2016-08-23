Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50878 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750775AbcHWPKb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 Aug 2016 11:10:31 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id CA402C05678C
        for <linux-nfs@vger.kernel.org>; Tue, 23 Aug 2016 15:09:38 +0000 (UTC)
Received: from [10.10.63.132] (vpn-63-132.rdu2.redhat.com [10.10.63.132])
        by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u7NF9bM3031914
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
        for <linux-nfs@vger.kernel.org>; Tue, 23 Aug 2016 11:09:38 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "List Linux NFS Mailing" <linux-nfs@vger.kernel.org>
Subject: I can't get no readdir satisfaction
Date: Tue, 23 Aug 2016 11:09:37 -0400
Message-ID: <778246F3-8F24-48FD-AEA9-0BCC0DCD93B3@redhat.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi linux-nfs,

311324ad1713 ("NFS: Be more aggressive in using readdirplus for 'ls -l'
situations") changed when nfs_readdir() decides to revalidate the
directory's mapping, which contains all the entries.  In addition to just
checking if the attribute cache has expired, it includes a check to see if
NFS_INO_INVALID_DATA is set on the directory.

Well, customers that have directories with very many dentries and that same
directory's attributes are frequently updated are now grouchy that `ls -l`
takes so long since any update of the directory causes the mapping to be
invalidated and we have to start over filling the directory's mapping.

I actually haven't put real hard thought into it yet (because often for me
that just wastes a lot of time), so I am doing the lazy thing by asking this
question:

Can we go back to just the using the attribute cache timeout, or should we
get all heuristical about readdir?

Ben
