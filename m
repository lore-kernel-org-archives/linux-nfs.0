Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57750 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755282Ab1JTKCD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Oct 2011 06:02:03 -0400
Date: Thu, 20 Oct 2011 06:02:02 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] CLNT: add some tests for DESTROY_CLIENTID
Message-ID: <20111020100202.GF5444@fieldses.org>
References: <4E9FE273.80500@cn.fujitsu.com>
 <20111020094355.GE5444@fieldses.org>
 <4E9FF123.2060704@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E9FF123.2060704@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 20, 2011 at 06:00:03PM +0800, Mi Jinlong wrote:
> 
> 
> J. Bruce Fields:
> > There's just one other test I'd suggest: it would be useful to check
> > that the clientid has actually been destroyed.  So, destroy the
> > clientid, then try using it somehow (maybe by sending a create session?
> > Or just trying to use a session that belonged to that client?).
> 
>   I think Case DESCID7 is what you said. 

Whoops, you're right, I missed it.

--b.

>   
> thanks,
> Mi Jinlong
> 
> > 
> > --b.
> > 
> >> +
> >> +    FLAGS: destroy_clientid all
> >> +    CODE: DESCID4
> >> +    """
> >> +    c = env.c1.new_client(env.testname(t))
> >> +    sess = c.create_session()
> >> +
> >> +    res = sess.compound([op.destroy_clientid(c.clientid)])
> >> +    check(res, NFS4ERR_CLIENTID_BUSY)
> >> +
> >> +def testDestroyCIDInSession(t, env):
> >> +    """ destroy a clientid of other session without session
> >> +
> >> +    FLAGS: destroy_clientid all
> >> +    CODE: DESCID5
> >> +    """
> >> +    c = env.c1.new_client(env.testname(t))
> >> +    sess = c.create_session()
> >> +
> >> +    res = env.c1.compound([op.destroy_clientid(c.clientid)])
> >> +    check(res, NFS4ERR_CLIENTID_BUSY)
> >> +
> >> +def testDestroyCIDNotOnly(t, env):
> >> +    """ destroy a clientid without session with other compound
> >> +
> >> +    FLAGS: destroy_clientid all
> >> +    CODE: DESCID6
> >> +    """
> >> +    res = env.c1.compound([op.destroy_clientid(0), op.reclaim_complete(TRUE)])
> >> +    check(res, NFS4ERR_NOT_ONLY_OP)
> >> +
> >> +def testDestroyCIDTwice(t, env):
> >> +    """ destroy a clientid without session twice
> >> +
> >> +    FLAGS: destroy_clientid all
> >> +    CODE: DESCID7
> >> +    """
> >> +    c = env.c1.new_client(env.testname(t))
> >> +
> >> +    res = env.c1.compound([op.destroy_clientid(c.clientid)])
> >> +    check(res)
> >> +
> >> +    res = env.c1.compound([op.destroy_clientid(c.clientid)])
> >> +    check(res, NFS4ERR_STALE_CLIENTID)
> >> -- 
> >> 1.7.6
> >>
> >>
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> > 
> 
> -- 
> ----
> thanks
> Mi Jinlong
> 
