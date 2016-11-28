Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.46]:54905 "EHLO minas.ics.muni.cz"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751168AbcK1Sxd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 28 Nov 2016 13:53:33 -0500
Received: from anubis.ics.muni.cz (dell1.aetna.cz [77.240.179.195] (may be forged))
        (authenticated user=xhejtman@META bits=0)
        by minas.ics.muni.cz (8.14.4/8.14.4/Debian-4+deb7u1) with ESMTP id uASIbvVv004722
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT)
        for <linux-nfs@vger.kernel.org>; Mon, 28 Nov 2016 19:38:00 +0100
Received: from xhejtman by anubis.ics.muni.cz with local (Exim 4.87)
        (envelope-from <xhejtman@ics.muni.cz>)
        id 1cBQoP-0003Bp-Ji
        for linux-nfs@vger.kernel.org; Mon, 28 Nov 2016 19:37:57 +0100
Date: Mon, 28 Nov 2016 19:37:57 +0100
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
To: linux-nfs@vger.kernel.org
Subject: RFC rpc.gssd enhancement
Message-ID: <20161128183757.d5pz64tsigmaxdc7@ics.muni.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

would it be acceptable to add an option for rpc.gssd to use host keytab if
user's kerberos ticket is not available?

Consider the following scenario:
1) machine has NFS mounted /home using kerberos authentication
2) user logs in, sshd creates krb ticket ($HOME/.k5login needs to be world
readable to allow kerberized access, e.g., using kerberos ticket)
3) user stays logged in and krb ticket expires
4) kinit to renew ticket produces strange error because $HOME is not
accessible and a new ticket is not created.

So, I think in this case, I would like to see rpc.gssd uses host keytab while
user's ticket is not available, which maps to nobody/nogroup, but kinit should
succeed. 

Or are there any other options if one is using kerberized homes only?

-- 
Luká¹ Hejtmánek
