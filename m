Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58837 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754007Ab3C2Skj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Mar 2013 14:40:39 -0400
Date: Fri, 29 Mar 2013 14:40:31 -0400
To: Mimi Zohar <zohar@linux.vnet.ibm.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 02/14] Security: Add Hook to test if the particular xattr
 is part of a MAC model.
Message-ID: <20130329184031.GF22307@fieldses.org>
References: <1364478845-29796-1-git-send-email-SteveD@redhat.com>
 <1364478845-29796-3-git-send-email-SteveD@redhat.com>
 <1364557380.2580.189.camel@falcor1.watson.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1364557380.2580.189.camel@falcor1.watson.ibm.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 29, 2013 at 07:43:00AM -0400, Mimi Zohar wrote:
> On Thu, 2013-03-28 at 09:53 -0400, Steve Dickson wrote:
> > From: David Quigley <dpquigl@davequigley.com>
> > 
> > The interface to request security labels from user space is the xattr
> > interface. When requesting the security label from an NFS server it is
> > important to make sure the requested xattr actually is a MAC label. This allows
> > us to make sure that we get the desired semantics from the attribute instead of
> > something else such as capabilities or a time based LSM.
> > 
> > Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
> > Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
> > Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
> > Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
> > ---
> >  include/linux/security.h   | 14 ++++++++++++++
> >  security/capability.c      |  6 ++++++
> >  security/security.c        |  6 ++++++
> >  security/selinux/hooks.c   |  6 ++++++
> >  security/smack/smack_lsm.c | 11 +++++++++++
> >  5 files changed, 43 insertions(+)
> > 
> > diff --git a/include/linux/security.h b/include/linux/security.h
> > index a957e7a..8a6faff 100644
> > --- a/include/linux/security.h
> > +++ b/include/linux/security.h
> > @@ -1319,6 +1319,13 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
> >   *	@pages contains the number of pages.
> >   *	Return 0 if permission is granted.
> >   *
> > + * @ismaclabel:
> > + *	Check if the extended attribute specified by @name
> > + *	represents a MAC label. Returns 0 if name is a MAC
> > + *	attribute otherwise returns non-zero.
> 
> Sorry, the comment doesn't match the code.

Yeah, that looks backwards.  Confirmed by looking at an implementation:

> > +static int selinux_ismaclabel(const char *name)
> > +{
> > +	return (strcmp(name, XATTR_SELINUX_SUFFIX) == 0);
> > +}
> > +

Could we also make the return value bool to make it even less ambiguous?

--b.
