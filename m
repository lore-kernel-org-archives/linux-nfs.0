From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [PATCH v2 06/47] nfsd41: Add Kconfig symbols for NFSv4.1
Date: Thu, 2 Apr 2009 10:22:56 -0400
Message-ID: <20090402142256.GF24124@fieldses.org>
References: <1238229069-8636-1-git-send-email-bhalevy@panasas.com> <20090401043301.GA29339@fieldses.org> <49D32659.8040207@panasas.com> <20090401131022.GA4002@fieldses.org> <49D3752E.7060708@panasas.com> <49D38924.9020105@panasas.com> <49D482F6.5090000@panasas.com> <20090402132742.GA24124@fieldses.org> <49D4C19F.7090608@panasas.com> <1238681800.6191.5.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benny Halevy <bhalevy@panasas.com>,
	Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:44302 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756382AbZDBOXA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 10:23:00 -0400
In-Reply-To: <1238681800.6191.5.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 02, 2009 at 10:16:40AM -0400, Trond Myklebust wrote:
> On Thu, 2009-04-02 at 16:46 +0300, Benny Halevy wrote:
> > On Apr. 02, 2009, 16:27 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > On Thu, Apr 02, 2009 at 12:18:46PM +0300, Benny Halevy wrote:
> > >> On Apr. 01, 2009, 18:32 +0300, Benny Halevy <bhalevy@panasas.com> wrote:
> > >>> On Apr. 01, 2009, 17:07 +0300, Benny Halevy <bhalevy@panasas.com> wrote:
> > >>>> On Apr. 01, 2009, 16:10 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > >>>>> On Wed, Apr 01, 2009 at 11:31:21AM +0300, Benny Halevy wrote:
> > >>>>>> On Apr. 01, 2009, 7:33 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > >>>>>>> On Sat, Mar 28, 2009 at 11:31:09AM +0300, Benny Halevy wrote:
> > >>>>>>>> Added CONFIG_NFSD_V4_1 and made it depend upon NFSD_V4 and EXPERIMENTAL
> > >>>>>>>> Indicate that CONFIG_NFS_V4_1 is for NFS developers at the moment
> > >>>>>>> Stupid question: do we need CONFIG_NFSD_V4_1 at all?  How many people
> > >>>>>>> will want to build a kernel with v4.0 but not v4.1?
> > >> Bruce,  with the patch below in place, would it be reasonable to
> > >> remove CONFIG_NFSD_V4_1?
> > > 
> > > It would be fine with me, but perhaps queuing that up as a separate
> > > patch for 2.6.31 would be better than doing it at the last moment.
> > 
> > It's not too hard to get rid of it now.
> > I think it might be better than introducing a new config item
> > to be removed in the next version.
> > 
> > Trond, please speak up if you want to remove CONFIG_NFS_V4_1 as well.
> > On the client side minorversion 1 will be used only if the user
> > explicitly asked for it with mount -o minorversion=1.
> 
> I'd feel more comfortable with being able to compile it out until the
> stability of the code has been established. I'd certainly want to be
> able to do that on the server side, since it has no other means to
> restrict the protocol version should it turn out that NFSv4.1 has some
> fatal condition.

I think it's acceptable given an interface that allows choosing the
supported minorversion at runtime (and that defaults 4.1 to off).

--b.
