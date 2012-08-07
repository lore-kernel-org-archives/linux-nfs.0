Return-Path: linux-nfs-owner@vger.kernel.org
Received: from minas.ics.muni.cz ([147.251.4.40]:57923 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751370Ab2HGQMX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Aug 2012 12:12:23 -0400
Date: Tue, 7 Aug 2012 18:12:11 +0200
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 backchannel authentication
Message-ID: <20120807161211.GL11089@ics.muni.cz>
References: <20120806135517.GS25979@ics.muni.cz>
 <20120807154114.GA21460@fieldses.org>
 <1344355148.5781.31.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
In-Reply-To: <1344355148.5781.31.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 07, 2012 at 03:59:09PM +0000, Myklebust, Trond wrote:
> Yes, you can do this, however that requires the server to be configured
> to accept rpcsec_gss and auth_sys from that client.
> It also allows anyone to spoof a callback to your client.
> Furthermore, it would allow anybody to send SETCLIENTID calls using the
> same client id to the server and so they can declare your client to have
> rebooted (so that all state is lost), they can divert callbacks to
> another machine, ....
> IOW: it is not really something you want to allow on an untrusted
> network.

well, ok, thanks for anwsers. However, it seems that while NFS server's name
is server-home.domain.com (floating name), and true hostname is
server1.domain.com, it does not matter that callback is authenticated with
server1.domain.com instead of server-home.domain.com.

Is this expected? Or is it a bug?

I would suppose that client rejects authentication of the backchannel from 
server that sends nfs/server1.domain.com KRB principal instead of expected
nfs/server-home.domain.com. 

The client mounts server-home.domain.com with sec=krb5i. Using debugs I can
see that the server picks up nfs/server1.domain.com key from /etc/krb5.keytab
and the client seems to be happy with that (context is established).

-- 
Luká¹ Hejtmánek
