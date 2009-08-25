From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: mount.nfs: access denied by server
Date: Tue, 25 Aug 2009 14:43:17 -0400
Message-ID: <1251225797.25372.25.camel@heimdal.trondhjem.org>
References: <31F3372A-891E-44EF-8DD2-78D5A3AD5CF1@oracle.com>
	 <20090821200403.GA23529@fieldses.org>
	 <EB232FA3-96EF-4332-94D5-61F465912838@oracle.com>
	 <1250889345.5700.11.camel@heimdal.trondhjem.org>
	 <20090821213016.GG23529@fieldses.org>
	 <1250890836.5700.19.camel@heimdal.trondhjem.org>
	 <20090821214720.GH23529@fieldses.org>
	 <1250891463.5700.21.camel@heimdal.trondhjem.org>
	 <20090824161004.GB4985@fieldses.org>
	 <1251133618.6325.262.camel@heimdal.trondhjem.org>
	 <20090824174129.GD4985@fieldses.org>
	 <1EEDD90B-709F-4C78-97B4-6107AE100162@oracle.com> <4A94162C.20904@sun.com>
	 <1251219492.25372.3.camel@heimdal.trondhjem.org> <4A942ACF.4030502@sun.com>
	 <1251225543.25372.22.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS list <linux-nfs@vger.kernel.org>, nfs-discuss-xZgeD5Kw2fzokhkdeNNY6A@public.gmane.org
To: Tom Haynes <Thomas.Haynes-UdXhSnd/wVw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24088 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755581AbZHYSnQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Aug 2009 14:43:16 -0400
In-Reply-To: <1251225543.25372.22.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-08-25 at 14:39 -0400, Trond Myklebust wrote:
> On Tue, 2009-08-25 at 13:17 -0500, Tom Haynes wrote:
> > Trond Myklebust wrote:
> > > On Tue, 2009-08-25 at 11:49 -0500, Tom Haynes wrote:
> > >   
> > >> With OpenSolaris NFSv3, there is no autonegotiation.  With NFSv4, we 
> > >> support the autonegotiation
> > >> as defined in the protocol.
> > >>
> > >> We just went through a regression with this algorithm.
> > >>     
> > >
> > > NFSv4 also allows the server to change the list of supported security
> > > flavours on the fly at any point in the namespace, and at any time. How
> > > does OpenSolaris currently deal with this?
> > >
> > >   
> > 
> > The client gets a WRONGSEC and then initiates auto-negotiation.
> > 
> 
> Right, but are there any limits to that?
> 
> Will it, for instance, allow process 1 to continue using auth_sys, while
> process 2 switches to using krb5 on the same file?
> 
> Should it recover in the case where the administrator suddenly removes
> krb5 from the list, and replaces it with krb5i on all subdirectories
> of ../../.. relative to your current working directory?

Sorry. Let me be more specific...

Say you have

/foo sec=krb5,rw

and the administrator adds a new rule

/foo/bar sec=krb5i,rw

Will your autonegotiator be able to recover processes that are working
in /foo/bar/... without disturbing those working in /foo/baz/... ?

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
