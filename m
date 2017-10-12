Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36998 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755605AbdJLTts (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 12 Oct 2017 15:49:48 -0400
Date: Thu, 12 Oct 2017 15:49:46 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Thomas Haynes <loghyr@primarydata.com>
Cc: Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>
Subject: Re: pynfs replay cache test SEQ9f
Message-ID: <20171012194946.GC5233@fieldses.org>
References: <1507740502-5151-1-git-send-email-Thomas.Haynes@primarydata.com>
 <E0161195-9F4A-4B36-A71D-6A924498C893@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <E0161195-9F4A-4B36-A71D-6A924498C893@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 12, 2017 at 06:32:09PM +0000, Thomas Haynes wrote:
> Hi Bruce,
> 
> In this test:
> 
> def testReplayCache006(t, env):
>    """Send two solo sequence compounds with same seqid
> 
>    FLAGS: sequence all
>    CODE: SEQ9f
>    """
>    c = env.c1.new_client(env.testname(t))
>    sess = c.create_session()
>    res1 = sess.compound([])
>    check(res1)
>    res2 = sess.compound([], cache_this=True, seq_delta=0)
>    check(res2)
>    res1.tag = res2.tag = ""
>    if not nfs4lib.test_equal(res1, res2):
>        fail("Replay results not equal")
> 
> I don't see why the result should be NFS4_OK.
> 
> The first compound does not set sa_cachethis and the second
> does set it. According to RFC5661, the server is not required
> to cache the first request if the client does not request it.
> 
> And if the server does not cache the response, when it gets
> a request to replay it, it can return NFS4ERR_RETRY_UNCACHED_REP:

If I'm reading that section correctly, it can't return
NFS4ERR_RETRY_UNCACHED_REP, that can only be returned on the next op of
the compound (and there is no next op in this case, only the one
SEQUENCE).

So I *think* the only correct options OK or FALSE_RETRY?

> I'm not sure if the test should be fixed to either
> 
> 1) allow either NFS4_OK or NFS4ERR_RETRY_UNCACHED_REP
> 2) just remove the test.

Maybe just add cache_this to the first?

Looks like the following test is off too--I think a server's allowed to
return a cached reply instead of RETRY_UNCACHED_REP?

--b.
