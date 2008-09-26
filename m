From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 07/10] lockd: Remove unused fields in the nlm_reboot
	structure
Date: Fri, 26 Sep 2008 19:07:05 -0400
Message-ID: <20080926230705.GJ7138@fieldses.org>
References: <20080917161337.4963.74674.stgit@ellison.1015granger.net> <20080917161804.4963.71981.stgit@ellison.1015granger.net> <20080926225331.GI7138@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:60599 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752332AbYIZXHH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 19:07:07 -0400
In-Reply-To: <20080926225331.GI7138@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 26, 2008 at 06:53:31PM -0400, bfields wrote:
> On Wed, Sep 17, 2008 at 11:18:04AM -0500, Chuck Lever wrote:
> > The nlm_reboot structure is used to store information provided by the
> > NSM_NOTIFY procedure.  This procedure is not specified by the NLM or NSM
> > protocols, other than to say that the procedure can be used to transmit
> > information private to a particular NLM/NSM implementation.
> > 
> > For Linux, the callback arguments include the name of the monitored host,
> > the new NSM state of the host, and a 16-byte private opaque.
> > 
> > Linux encodes the monitored host's IP address into the opaque field.
> > Formerly, this field contained a 4-byte in_addr IPv4 address and the NSM
> > version and transport protocol used to contact the monitored host.
> > Recently this was changed so that the private field now contains the
> > 4-byte IPv4 address and 12 bytes of zero.
> > 
> > As a clean up, remove the unused fields and the server-side XDR logic that
> > decodes them.
> 
> My one concern here:
> 
> > diff --git a/include/linux/lockd/xdr.h b/include/linux/lockd/xdr.h
> > index df18fa0..d6b3a80 100644
> > --- a/include/linux/lockd/xdr.h
> > +++ b/include/linux/lockd/xdr.h
> > @@ -81,8 +81,6 @@ struct nlm_reboot {
> >  	unsigned int	len;
> >  	u32		state;
> >  	__be32		addr;
> > -	__be32		vers;
> > -	__be32		proto;
> >  };
> 
> is that sizeof(nlm_reboot) is used to set pc_argsize in the PROC()
> macro's at the end of svcproc.c and svc4proc.c.  On a quick glance I can
> see any problem that that would cause.  Have you checked this?

Never mind, I think I was assuming there was some connection between the
size of this struct and the on-the-wire xdr size, which isn't the case.
OK, this shouldn't matter at all.

--b.
