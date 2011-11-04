Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52741 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753132Ab1KDWSE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Nov 2011 18:18:04 -0400
Date: Fri, 4 Nov 2011 18:18:03 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/3] 4.1 CLNT: Create session before using at OPEN6
Message-ID: <20111104221803.GM721@fieldses.org>
References: <4EAA7C9C.6050601@cn.fujitsu.com>
 <20111104215211.GK721@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111104215211.GK721@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 04, 2011 at 05:52:11PM -0400, J. Bruce Fields wrote:
> On Fri, Oct 28, 2011 at 05:57:48PM +0800, Mi Jinlong wrote:
> > 4.1 CLNT: Create session before using at OPEN6
> 
> Makes sense--but then how did this test ever work?

Oh, I see, it didn't--I just added it to the skip-list for my tests
without investigating.

Thanks, applied!

--b.

> 
> --b.
> 
> > 
> > Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> > ---
> >  nfs4.1/server41tests/st_open.py |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/nfs4.1/server41tests/st_open.py b/nfs4.1/server41tests/st_open.py
> > index 2aa3ec4..bd995a5 100644
> > --- a/nfs4.1/server41tests/st_open.py
> > +++ b/nfs4.1/server41tests/st_open.py
> > @@ -192,7 +192,7 @@ def testEXCLUSIVE4AtNameAttribute(t, env):
> >      FLAGS: open all
> >      CODE: OPEN6
> >      """
> > -    sess1 = env.c1.new_client(env.testname(t))
> > +    sess1 = env.c1.new_client_session(env.testname(t))
> >  
> >      res = create_file(sess1, env.testname(t), mode=EXCLUSIVE4_1)
> >      check(res)
> > -- 
> > 1.7.5.1
> > 
> > 
