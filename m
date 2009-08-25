From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: mount.nfs: access denied by server
Date: Tue, 25 Aug 2009 19:20:16 -0400
Message-ID: <1251242416.5403.3.camel@heimdal.trondhjem.org>
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
	 <1251225797.25372.25.camel@heimdal.trondhjem.org>
	 <4A9462E4.5020404@sun.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS list <linux-nfs@vger.kernel.org>, nfs-discuss-xZgeD5Kw2fzokhkdeNNY6A@public.gmane.org
To: Tom Haynes <Thomas.Haynes-UdXhSnd/wVw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56109 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932255AbZHYXUX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Aug 2009 19:20:23 -0400
In-Reply-To: <4A9462E4.5020404-xsfywfwIY+M@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-08-25 at 17:17 -0500, Tom Haynes wrote:
> Trond Myklebust wrote:
> >> Should it recover in the case where the administrator suddenly removes
> >> krb5 from the list, and replaces it with krb5i on all subdirectories
> >> of ../../.. relative to your current working directory?
> >>     
> >
> > Sorry. Let me be more specific...
> >
> > Say you have
> >
> > /foo sec=krb5,rw
> >
> > and the administrator adds a new rule
> >
> > /foo/bar sec=krb5i,rw
> >
> > Will your autonegotiator be able to recover processes that are working
> > in /foo/bar/... without disturbing those working in /foo/baz/... ?
> >
> >   
> 
> 
> I'll let someone who knows the client give the real response, but 
> consider two
> threads, one in /foo/baz and one in /foo/bar.
> 
> The one in /foo/baz will never get a WRONGSEC.
> 
> The one in /foo/bar may never get one either - depending on the server 
> implementation.
> i.e., the server has probably put the FSID in the FH. The client is 
> handing back
> what is probably a non-volatile FH and the server has to honor it. And 
> the server
> may have no clue that the FH is under a new mount point.
> 
> What happens if the client redrives a LOOKUP of the directory entry? It 
> should
> discover that the FHs no longer match and do some sort of recovery.

I was thinking of the case in which /foo/bar is not actually a mount
point. :-)

If we all agree that the server can only remove security flavours when
crossing a mount point, then all is well, however the protocol doesn't
strictly speaking say that has to be the case.
That worries me...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
