Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e39.co.us.ibm.com ([32.97.110.160]:50070 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753249Ab3F0WcX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Jun 2013 18:32:23 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Thu, 27 Jun 2013 16:32:23 -0600
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 78557C90042
	for <linux-nfs@vger.kernel.org>; Thu, 27 Jun 2013 18:32:20 -0400 (EDT)
Received: from d01av05.pok.ibm.com (d01av05.pok.ibm.com [9.56.224.195])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5RMWKnh51052670
	for <linux-nfs@vger.kernel.org>; Thu, 27 Jun 2013 18:32:20 -0400
Received: from d01av05.pok.ibm.com (loopback [127.0.0.1])
	by d01av05.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5RMWJgB001587
	for <linux-nfs@vger.kernel.org>; Thu, 27 Jun 2013 18:32:20 -0400
In-Reply-To: <606311159.195.1372362069589.JavaMail.root@thunderbeast.private.linuxbox.com>
References: <1444224014.193.1372361256986.JavaMail.root@thunderbeast.private.linuxbox.com> <606311159.195.1372362069589.JavaMail.root@thunderbeast.private.linuxbox.com>
To: "Matt W. Benjamin" <matt@linuxbox.com>
Cc: "Adam C. Emerson" <aemerson@linuxbox.com>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Subject: Re: NFSv4.1 session
Message-ID: <OF23EDFA89.935AA03E-ON88257B97.007B822F-88257B97.007BCF70@us.ibm.com>
From: Marc Eshel <eshel@us.ibm.com>
Date: Thu, 27 Jun 2013 15:32:16 -0700
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"Matt W. Benjamin" <matt@linuxbox.com> wrote on 06/27/2013 12:41:09 PM:

> From: "Matt W. Benjamin" <matt@linuxbox.com>
> To: Marc Eshel/Almaden/IBM@IBMUS, 
> Cc: "Adam C. Emerson" <aemerson@linuxbox.com>, "J. Bruce Fields" 
> <bfields@redhat.com>, linux-nfs@vger.kernel.org, Trond Myklebust 
> <Trond.Myklebust@netapp.com>
> Date: 06/27/2013 12:41 PM
> Subject: Re: NFSv4.1 session
> 
> Hi,
> 
> Keeping this simple, the controlling section of RFC 5661 is 2.10.5 
(trunking).
> 
> If CLIENT presents the same eia_clientowner in two EXCHANGE_ID 
invocations
> to "the same NFSv4.1 server" over two connections of differing network
> address, 2.10.5 actually states that the server MUST return the same
> value for eir_serverowner.  By our choice of the same server owner, we 
are
> consenting to clientid trunking.
> 
> It doesn't seem like anything stops one instance of Ganesha from 
> presenting itself
> as two or more completely distinct NFSv4.1 servers in response to 
> connections of
> differing address.  They could share the same server scope (e.g., 
> filehandle namespaces),

Maybe we can do that but Ganesha will have to change from identifying 
clients only based on the client-id to combination of client-id and server 
instance.

Marc. 

> but they CANNOT share the same server owner, and consequently, they 
> can't share
> any state.  (So we think it would confuse the client if we return 
CLID_INUSE
> on the second EXCHANGE_ID.)
> 
> Matt and Adam
> 
> ----- "Marc Eshel" <eshel@us.ibm.com> wrote:
> 
> > If it was not clear I am talking about the exchange id operation.
> > Marc.
> > 
> > 
> > 
> > From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
> > To: Marc Eshel/Almaden/IBM@IBMUS,
> > Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, "J. Bruce
> > Fields" <bfields@redhat.com>, "Adam C. Emerson"
> > <aemerson@linuxbox.com>, "Matt W. Benjamin" <matt@linuxbox.com>
> > Date: 06/27/2013 11:09 AM
> > Subject: Re: NFSv4.1 session
> > 
> > 
> > 
> > 
> > On Thu, 2013-06-27 at 11:00 -0700, Marc Eshel wrote:
> > > Hi Trond,
> > >
> > > I am not able to mount from Linux NFS client to the same Ganesha NFS
> > > server using multiple IP address. The client was providing the same
> > > client-id so the server was using the same session. I tried to
> > return
> > > NFS4ERR_CLID_INUSE on the second mount if the target IP is different
> > > but the client still did not provide a different client-id like it
> > > should. I am not trying to use trunking I what to have different
> > > server instance for each IP address so I can move that IP between
> > > nodes in the cluster. Any ideas how to accomplish it.
> > >
> > > Thanks, Marc.
> > 
> > I don't understand. The client is performing exactly as per design: it
> > detects the fact that you are talking to the same server, and so it
> > reuses the same client and session. This is the only sane semantic for
> > a
> > NFS client...
> > 
> > --
> > Trond Myklebust
> > Linux NFS client maintainer
> > 
> > NetApp
> > Trond.Myklebust@netapp.com
> > www.netapp.com
> 
> -- 
> Matt Benjamin
> The Linux Box
> 206 South Fifth Ave. Suite 150
> Ann Arbor, MI  48104
> 
> http://linuxbox.com
> 
> tel.  734-761-4689 
> fax.  734-769-8938 
> cel.  734-216-5309 
> 

