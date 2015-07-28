Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60551 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751865AbbG1R6T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Jul 2015 13:58:19 -0400
Date: Tue, 28 Jul 2015 13:58:18 -0400
From: "'J. Bruce Fields'" <bfields@fieldses.org>
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: "'Kinglong Mee'" <kinglongmee@gmail.com>, linux-nfs@vger.kernel.org,
        tigran.mkrtchyan@desy.de
Subject: Re: [PATCH 4/4] 4.1 create_session: Skip test of CB_NULL for nfs4.1
Message-ID: <20150728175818.GD20951@fieldses.org>
References: <55B76B9D.2090103@gmail.com>
 <008401d0c94e$f90e7250$eb2b56f0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <008401d0c94e$f90e7250$eb2b56f0$@mindspring.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 28, 2015 at 09:03:38AM -0700, Frank Filz wrote:
> Why are we removing these two test cases? The Ganesha NFS server at least passes them.

And there's nothing wrong with passing the tests, but unfortunately
there's not necessarily anything wrong with failing either: a 4.1 server
isn't required to do a NULL callback to probe the backchannel.

There might be a better test (depend on delegation recalls instead of
CB_NULL's?), till then I'm OK with turning them off by default.

--b.

> 
> Frank
> 
> > -----Original Message-----
> > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> > owner@vger.kernel.org] On Behalf Of Kinglong Mee
> > Sent: Tuesday, July 28, 2015 4:47 AM
> > To: J. Bruce Fields; linux-nfs@vger.kernel.org
> > Cc: tigran.mkrtchyan@desy.de; kinglongmee@gmail.com
> > Subject: [PATCH 4/4] 4.1 create_session: Skip test of CB_NULL for nfs4.1
> > 
> > Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> > ---
> >  nfs4.1/server41tests/st_create_session.py | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/nfs4.1/server41tests/st_create_session.py
> > b/nfs4.1/server41tests/st_create_session.py
> > index b42e0ab..4c56bb4 100644
> > --- a/nfs4.1/server41tests/st_create_session.py
> > +++ b/nfs4.1/server41tests/st_create_session.py
> > @@ -333,7 +333,7 @@ def testManyClients(t, env):
> >  def testCallbackProgram(t, env):
> >      """Check server can handle random transient program number
> > 
> > -    FLAGS: create_session all
> > +    FLAGS:
> >      CODE: CSESS20
> >      """
> >      cb_occurred = threading.Event()
> > @@ -360,7 +360,7 @@ def testCallbackProgram(t, env):
> >  def testCallbackVersion(t, env):
> >      """Check server sends callback program with a version listed in
> > nfs4client.py
> > 
> > -    FLAGS: create_session all
> > +    FLAGS:
> >      CODE: CSESS21
> >      """
> >      cb_occurred = threading.Event()
> > --
> > 2.4.3
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the
> > body of a message to majordomo@vger.kernel.org More majordomo info at
> > http://vger.kernel.org/majordomo-info.html
