Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49136 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752320Ab1CWRHR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Mar 2011 13:07:17 -0400
Subject: Re: different kernels mean NFS4/GSSAPI works or doesn't
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "Brian J. Murrell" <brian@interlinx.bc.ca>
Cc: linux-nfs@vger.kernel.org, Kevin Coffman <kwc@citi.umich.edu>
In-Reply-To: <4D8A0C9F.8090300@interlinx.bc.ca>
References: <imbb8m$uiv$1@dough.gmane.org>
	 <AANLkTimFJ2fMn805jY91u8FQihib8GfJ=8S7Yy4y47R3@mail.gmail.com>
	 <4D89D36D.3090207@interlinx.bc.ca>
	 <AANLkTi=b1z0MrYYQmidbra0EHanegcLO5qoOScLq21rb@mail.gmail.com>
	 <4D8A0C9F.8090300@interlinx.bc.ca>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 23 Mar 2011 13:07:15 -0400
Message-ID: <1300900035.11677.12.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Please don't remove people from the Cc list.

On Wed, 2011-03-23 at 11:07 -0400, Brian J. Murrell wrote:
> On 11-03-23 10:29 AM, Kevin Coffman wrote:
> > 
> > However, that doesn't appear to be the case from looking at the
> > gssd/svcgssd output.  Have you checked the server's syslog for
> > messages about rpc.gssd not running?
> 
> Yup.  Nothing there.
> 
> > OK.  Thanks.  There is enough info there, even with the redaction.
> 
> Ahhh.  Good.
> 
> > This shows that a des (enctype 4) session key is being negotiated and
> > delivered to both kernels, so I don't think any of the Kerberos issues
> > should be involved here.  (At least from the user-land perspective.)
> 
> Hrm.  So this gets even more interesting (for some values of "interesting").
> 
> > I'm not sure what kernel change would be causing your hang ...
> 
> Thanks for looking though.
> 
> I'm open to any more ideas, debugging info requests, etc. that anyone
> might have.

You said this happens only with RPCSEC_GSS?

Have you tried bisecting, to see which changes caused it? You can
probably restrict yourself to bisecting changes to include/linux/sunrpc,
net/sunrpc and net/sunrpc/auth_gss.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

