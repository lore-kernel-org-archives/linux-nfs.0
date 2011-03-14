Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52857 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753494Ab1CNTYf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Mar 2011 15:24:35 -0400
Date: Mon, 14 Mar 2011 15:24:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 10/17] CLNT: test resues slot ID
Message-ID: <20110314192434.GC25442@fieldses.org>
References: <4D6DE26C.3010103@cn.fujitsu.com>
 <4D6DE4A5.1050702@cn.fujitsu.com>
 <20110303061442.GE7724@fieldses.org>
 <4D6F5B4E.7000903@cn.fujitsu.com>
 <4D70AB97.3070502@cn.fujitsu.com>
 <20110314184144.GB25442@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110314184144.GB25442@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Mar 14, 2011 at 02:41:44PM -0400, J. Bruce Fields wrote:
> On Fri, Mar 04, 2011 at 05:06:31PM +0800, Mi Jinlong wrote:
> >    Maybe the following one is better than before.
> 
> Looks good to me, thanks!

But on testing I get a failure:

SEQ14    st_sequence.testReuseSlotID                              : FAILURE
           AttributeError: LOOKUP4res instance has no attribute
	   'object'

I haven't tried to figure out what's going on there.

--b.

> 
> Very minor nit:
> 
> > +def testReuseSlotID(t, env):
> > +    """ If client reuses a slot ID and sequence ID for a completely
> > +        different request, server MAY treat the request as if it is
> > +        a retry of what it has already executed. rfc5661 18.46.3
> > +
> > +    FLAGS: sequence all
> > +    CODE: SEQ14
> > +    """
> > +    c = env.c1.new_client(env.testname(t))
> > +    # CREATE_SESSION
> > +    sess1 = c.create_session()
> > +
> > +    name = "%s_1" % env.testname(t)
> > +    res = create_file(sess1, name) 
> 
> Could you check your patches for trailing whitespace?  (There's an extra
> space at the end of that line.)
> 
> (No need to resend anything.)
> 
> --b.
> 
> > +    check(res)
> > +
> > +    sid = sess1.sessionid
> > +    seqid = nfs4lib.inc_u32(sess1.seqid)
> > +    fh = res.resarray[3].object
> > +    homedir = sess1.c.homedir[0]
> > +
> > +    res = c.c.compound([op.sequence(sid, seqid, 0, 0, TRUE), op.putrootfh(),
> > +                        op.lookup(homedir), op.remove(name)])
> > +    check(res)
> > +
> > +    # Reuses slot ID and sequence ID for different request
> > +    res = c.c.compound([op.sequence(sid, seqid, 0, 0, TRUE), op.putrootfh(),
> > +                        op.lookup(homedir), op.rename(name, "test")])
> > +    check(res)
> > -- 
> > 1.7.4.1
> > 
> > 
