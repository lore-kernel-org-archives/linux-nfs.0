Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([69.128.83.226]:1267 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753652Ab3F0Tro (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Jun 2013 15:47:44 -0400
Date: Thu, 27 Jun 2013 15:41:09 -0400 (EDT)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: Marc Eshel <eshel@us.ibm.com>
Cc: "Adam C. Emerson" <aemerson@linuxbox.com>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Message-ID: <606311159.195.1372362069589.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <1444224014.193.1372361256986.JavaMail.root@thunderbeast.private.linuxbox.com>
Subject: Re: NFSv4.1 session
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Keeping this simple, the controlling section of RFC 5661 is 2.10.5 (trunking).

If CLIENT presents the same eia_clientowner in two EXCHANGE_ID invocations
to "the same NFSv4.1 server" over two connections of differing network
address, 2.10.5 actually states that the server MUST return the same
value for eir_serverowner.  By our choice of the same server owner, we are
consenting to clientid trunking.

It doesn't seem like anything stops one instance of Ganesha from presenting itself
as two or more completely distinct NFSv4.1 servers in response to connections of
differing address.  They could share the same server scope (e.g., filehandle namespaces),
but they CANNOT share the same server owner, and consequently, they can't share
any state.  (So we think it would confuse the client if we return CLID_INUSE
on the second EXCHANGE_ID.)

Matt and Adam

----- "Marc Eshel" <eshel@us.ibm.com> wrote:

> If it was not clear I am talking about the exchange id operation.
> Marc.
> 
> 
> 
> From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
> To: Marc Eshel/Almaden/IBM@IBMUS,
> Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, "J. Bruce
> Fields" <bfields@redhat.com>, "Adam C. Emerson"
> <aemerson@linuxbox.com>, "Matt W. Benjamin" <matt@linuxbox.com>
> Date: 06/27/2013 11:09 AM
> Subject: Re: NFSv4.1 session
> 
> 
> 
> 
> On Thu, 2013-06-27 at 11:00 -0700, Marc Eshel wrote:
> > Hi Trond,
> >
> > I am not able to mount from Linux NFS client to the same Ganesha NFS
> > server using multiple IP address. The client was providing the same
> > client-id so the server was using the same session. I tried to
> return
> > NFS4ERR_CLID_INUSE on the second mount if the target IP is different
> > but the client still did not provide a different client-id like it
> > should. I am not trying to use trunking I what to have different
> > server instance for each IP address so I can move that IP between
> > nodes in the cluster. Any ideas how to accomplish it.
> >
> > Thanks, Marc.
> 
> I don't understand. The client is performing exactly as per design: it
> detects the fact that you are talking to the same server, and so it
> reuses the same client and session. This is the only sane semantic for
> a
> NFS client...
> 
> --
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

-- 
Matt Benjamin
The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel.  734-761-4689 
fax.  734-769-8938 
cel.  734-216-5309 
