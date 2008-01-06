From: James Morris <jmorris@namei.org>
Subject: Re: A new NFSv4 server...
Date: Mon, 7 Jan 2008 10:54:24 +1100 (EST)
Message-ID: <Xine.LNX.4.64.0801071010020.10819@us.intercode.com.au>
References: <477CD231.30603@garzik.org> <20080103163200.GB30029@fieldses.org>
 <477DC501.3060104@garzik.org> <477DD11B.40909@melbourne.sgi.com>
 <477DDA86.6020100@garzik.org> <Pine.LNX.4.64.0801040954070.5004@maggie.lkpg.cendio.se>
 <477E61D3.4030408@garzik.org> <Pine.LNX.4.64.0801042030380.18738@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="927316971-250219271-1199663664=:10819"
Cc: Jeff Garzik <jeff@garzik.org>,
	NFS list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org,
	mike-z9p9JiHjuePQT0dZR+AlfA@public.gmane.org
To: =?UTF-8?Q?Peter_=C3=85strand?= <astrand-+4tYiAq3b6azQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from namei.org ([69.55.235.186]:56085 "EHLO us.intercode.com.au"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754887AbYAFXyn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 6 Jan 2008 18:54:43 -0500
In-Reply-To: <Pine.LNX.4.64.0801042030380.18738-K9BqGu7AvB3wj5YHdwD3Ga2PxDmRETKR@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--927316971-250219271-1199663664=:10819
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 4 Jan 2008, Peter Åstrand wrote:

> > Use TLS to give most people what they want:  AUTH_SYS with encryption. GSSAPI
> > is fine as a "required option" but you shouldn't need GSSAPI to do simple wire
> > encryption between IP-authenticated hosts.
> 
> SSH is another option if you just want encryption, but my impression is 
> that AUTH_SYS is a very big problem as well. 

I've been looking into this recently, essentially ending up down a very 
similar track to the SSiLKey proposal presented at IETF67:

http://www3.ietf.org/proceedings/06nov/slides/spkm-5/spkm-5.ppt 

The basic idea in SSiLKey is to boostrap an RPCSEC_GSS session with TLS 
and then layer LIPKEY on top.

It seems to me that SSH might be preferrable to TLS as a low infrastucture 
mechanism, as many people already have ssh keys (and use them), there's no 
need for a HTTP server, and SSH already supports a variety of 
authentication mechanisms.

In the SSH case, I'm not sure yet whether LIPKEY would be the most 
appropriate mechanism to utilize, and whether this scheme might in fact be 
cleaner overall without using GSS at this level.  i.e. GSS can be used 
directly by SSH itself if desired, and there's also PAM.

There's also a patch for SSH to utilize GPG keys (raising the possibility 
of utilizing existing webs of trust), although it does not seem to be 
current.



- James
-- 
James Morris
<jmorris@namei.org>
--927316971-250219271-1199663664=:10819--
