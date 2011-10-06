Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:12406 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752250Ab1JFD2P convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Oct 2011 23:28:15 -0400
Subject: Re: [nfsv4] back channel flags, CREATE_SESSION, BIND_CONN_TO_SESSION
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "Matt W. Benjamin" <matt@linuxbox.com>
Cc: nfsv4 <nfsv4@ietf.org>, linux-nfs <linux-nfs@vger.kernel.org>,
        nfs-ganesha-devel <nfs-ganesha-devel@lists.sourceforge.net>
Date: Wed, 05 Oct 2011 23:28:13 -0400
In-Reply-To: <800236997.158.1317856908314.JavaMail.root@thunderbeast.private.linuxbox.com>
References: <800236997.158.1317856908314.JavaMail.root@thunderbeast.private.linuxbox.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1317871693.14305.5.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2011-10-05 at 19:21 -0400, Matt W. Benjamin wrote: 
> Hi,
> 
> There seem to be legitimate reasons for an (NFSv4.1) client and/or server to prefer a dedicated callback channel.

That would be an assertion that is missing a lot of context and
explanation. Why should my client bother to support such a server?

> If a server wants this result, it seems from the language of 18.36.3 that it should indicate it by not setting CREATE_SESSION4_FLAG_CONN_BACK_CHAN in csr_flags in the CREATE_SESSION response, presuming the flag is set in the corresponding csa_flags argument (it's not allowed to set it otherwise).  The client may respond with BIND_CONN_TO_SESSION on a new channel, setting bctsa_dir to CDFC4_BACK.

Nope. The exact wording is:

         If CREATE_SESSION4_FLAG_CONN_BACK_CHAN is set in csa_flags, the
         client is requesting that the connection over which the
         CREATE_SESSION operation arrived be associated with the
         session's backchannel in addition to its fore channel.  If the
         server agrees, it sets CREATE_SESSION4_FLAG_CONN_BACK_CHAN in
         the result field csr_flags.  If
         CREATE_SESSION4_FLAG_CONN_BACK_CHAN is not set in csa_flags,
         then CREATE_SESSION4_FLAG_CONN_BACK_CHAN MUST NOT be set in
         csr_flags.

I see nothing there to indicate that the server is able to request a
dedicated backchannel. All it says is that the server may refuse a
backchannel on this particular connection.

> Currently, the Linux and I believe also the CITI Windows client always propose channels in both directions.  The Linux mainline Linux client doesn't know how to BIND_CONN_TO_SESSION, so trivially it won't negotiate any back channel if a server didn't agree to both directions today, either.  I've experimentally implemented a "fallback" model in a Linux client and (partly in a) Ganesha server.  I'd appreciate any feedback on the idea.

Yep. As I said, why should we bother adding support for servers that
don't? I can function perfectly well without pNFS support or delegation
support in such a case. Performance will suck, but why do I care?

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

