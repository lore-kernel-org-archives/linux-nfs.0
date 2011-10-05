Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([134.215.213.37]:4708 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935485Ab1JEXg2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Oct 2011 19:36:28 -0400
Date: Wed, 5 Oct 2011 19:21:48 -0400 (EDT)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: nfsv4 <nfsv4@ietf.org>
Cc: nfs-ganesha-devel <nfs-ganesha-devel@lists.sourceforge.net>,
        linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <800236997.158.1317856908314.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <767481161.156.1317856859691.JavaMail.root@thunderbeast.private.linuxbox.com>
Subject: back channel flags, CREATE_SESSION, BIND_CONN_TO_SESSION
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

There seem to be legitimate reasons for an (NFSv4.1) client and/or server to prefer a dedicated callback channel.

If a server wants this result, it seems from the language of 18.36.3 that it should indicate it by not setting CREATE_SESSION4_FLAG_CONN_BACK_CHAN in csr_flags in the CREATE_SESSION response, presuming the flag is set in the corresponding csa_flags argument (it's not allowed to set it otherwise).  The client may respond with BIND_CONN_TO_SESSION on a new channel, setting bctsa_dir to CDFC4_BACK.

Currently, the Linux and I believe also the CITI Windows client always propose channels in both directions.  The Linux mainline Linux client doesn't know how to BIND_CONN_TO_SESSION, so trivially it won't negotiate any back channel if a server didn't agree to both directions today, either.  I've experimentally implemented a "fallback" model in a Linux client and (partly in a) Ganesha server.  I'd appreciate any feedback on the idea.

Thanks,

Matt

-- 

Matt Benjamin

The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel. 734-761-4689
fax. 734-769-8938
cel. 734-216-5309
