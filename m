Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45337 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753764Ab2C2Osp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Mar 2012 10:48:45 -0400
Date: Thu, 29 Mar 2012 10:48:43 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Matt W. Benjamin" <matt@linuxbox.com>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] nfsd4: use auth_unix unconditionally on backchannel
Message-ID: <20120329144843.GJ16938@fieldses.org>
References: <20120328234617.GB13231@fieldses.org>
 <1996969981.63.1333031372979.JavaMail.root@thunderbeast.private.linuxbox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1996969981.63.1333031372979.JavaMail.root@thunderbeast.private.linuxbox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 29, 2012 at 10:29:32AM -0400, Matt W. Benjamin wrote:
> Am I correct that this limitation is only with respect to v40 (that's how I read the comment and the code in fs/nfs/callback.c)?

I'm not sure what "limitation" you mean exactly....  The way the spec
works is (from memory, someone correct me if I screw up):

	- In the 4.0 case, the server's callbacks use the same flavor as
	  was used on the setclientid.
	- In the 4.1 case, the server's callbacks use the flavor
	  specified in the csa_sec_parms field in a create_session or
	  backchannel_ctl.

In the 4.1 case the client always requests auth_unix on the backchannel.
That is the client's right, and is an implementation choice based on the
assumption that the amount of mischief somebody could perform by reading
(or spoofing) callbacks is limited.

The Linux server correctly implements the 4.0 case, but in the 4.1 case
(after this patch, and before my earlier mistake in 80fc015bdfe) it
always uses auth_unix.  That happens to satisfy the linux client, but
isn't really correct, as it is perfectly legal for a client to request
something other than auth_unix, and the Linux server would currently
fail to interoperate with such a client.

--b.

> 
> Thanks,
> 
> Matt
> 
> ----- "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Wed, Mar 28, 2012 at 11:16:49PM +0000, Myklebust, Trond wrote:
> > > On Wed, 2012-03-28 at 19:09 -0400, J. Bruce Fields wrote:
> > > > This is a bandaid.
> > > > 
> > > > I have a series of patches that actually implement the correct
> > behavior,
> > > > but that may not quite be ready for 3.4.
> > > > 
> > > > --b.
> > > > 
> > > > commit 2f026867c76171d26f003b211063ff0562097d5e
> > > > Author: J. Bruce Fields <bfields@redhat.com>
> > > > Date:   Wed Mar 28 14:18:16 2012 -0400
> > > > 
> > > >     nfsd4: use auth_unix unconditionally on backchannel
> > > >     
> > > >     This isn't actually correct, but it works with the Linux
> > client, and
> > > >     agrees with the behavior we used to have before commit
> > 80fc015bdfe.
> > > 
> > > Question: does the Linux client ever send you anything other than
> > > AUTH_SYS credentials for the csa_sec_parms argument in
> > CREATE_SESSION?
> > > Anything other than that would be a bug, since our client doesn't
> > > actually support RPCSEC_GSS in the callback channel.
> > 
> > Right, I've never seen anything else, so I think the client's
> > behaving
> > as expected.
> > 
> > But the server needs to be fixed to deal with the range of possible
> > csa_sec_parms possibilities regardless.
> > 
> > The only thing I find odd about the client behavior is why it even
> > bothers with auth_sys when auth_null would work just as well and be
> > even
> > slightly simpler.
> > 
> > --b.
> > 
> > > 
> > > >     Later patches will implement the spec-mandated behavior (which
> > is to use
> > > >     the security parameters explicitly given by the client in
> > create_session
> > > >     or backchannel_ctl).
> > > >     
> > > 
> > > 
> > > -- 
> > > Trond Myklebust
> > > Linux NFS client maintainer
> > > 
> > > NetApp
> > > Trond.Myklebust@netapp.com
> > > www.netapp.com
> > > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> > in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> -- 
> Matt Benjamin
> The Linux Box
> 206 South Fifth Ave. Suite 150
> Ann Arbor, MI  48104
> 
> http://linuxbox.com
> 
> tel. 734-761-4689
> fax. 734-769-8938
> cel. 734-216-5309
