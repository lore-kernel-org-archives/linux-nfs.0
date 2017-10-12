Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:49713 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751682AbdJLScP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Oct 2017 14:32:15 -0400
From: Thomas Haynes <loghyr@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>
Subject: pynfs replay cache test SEQ9f
Date: Thu, 12 Oct 2017 18:32:09 +0000
Message-ID: <E0161195-9F4A-4B36-A71D-6A924498C893@primarydata.com>
References: <1507740502-5151-1-git-send-email-Thomas.Haynes@primarydata.com>
In-Reply-To: <1507740502-5151-1-git-send-email-Thomas.Haynes@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

In this test:

def testReplayCache006(t, env):
   """Send two solo sequence compounds with same seqid

   FLAGS: sequence all
   CODE: SEQ9f
   """
   c =3D env.c1.new_client(env.testname(t))
   sess =3D c.create_session()
   res1 =3D sess.compound([])
   check(res1)
   res2 =3D sess.compound([], cache_this=3DTrue, seq_delta=3D0)
   check(res2)
   res1.tag =3D res2.tag =3D ""
   if not nfs4lib.test_equal(res1, res2):
       fail("Replay results not equal")

I don't see why the result should be NFS4_OK.

The first compound does not set sa_cachethis and the second
does set it. According to RFC5661, the server is not required
to cache the first request if the client does not request it.

And if the server does not cache the response, when it gets
a request to replay it, it can return NFS4ERR_RETRY_UNCACHED_REP:

2.10.6.1.3.  Optional Reply Caching

  On a per-request basis, the requester can choose to direct the
  replier to cache the reply to all operations after the first
  operation (SEQUENCE or CB_SEQUENCE) via the sa_cachethis or
  csa_cachethis fields of the arguments to SEQUENCE or CB_SEQUENCE.
  The reason it would not direct the replier to cache the entire reply
  is that the request is composed of all idempotent operations [34].
  Caching the reply may offer little benefit.  If the reply is too
  large (see Section 2.10.6.4), it may not be cacheable anyway.  Even
  if the reply to idempotent request is small enough to cache,
  unnecessarily caching the reply slows down the server and increases
  RPC latency.

  Whether or not the requester requests the reply to be cached has no
  effect on the slot processing.  If the results of SEQUENCE or
  CB_SEQUENCE are NFS4_OK, then the slot's sequence ID MUST be
  incremented by one.  If a requester does not direct the replier to
  cache the reply, the replier MUST do one of following:

  o  The replier can cache the entire original reply.  Even though
     sa_cachethis or csa_cachethis is FALSE, the replier is always free
     to cache.  It may choose this approach in order to simplify
     implementation.

  o  The replier enters into its reply cache a reply consisting of the
     original results to the SEQUENCE or CB_SEQUENCE operation, and
     with the next operation in COMPOUND or CB_COMPOUND having the
     error NFS4ERR_RETRY_UNCACHED_REP.  Thus, if the requester later
     retries the request, it will get NFS4ERR_RETRY_UNCACHED_REP.  If a
     replier receives a retried Sequence operation where the reply to
     the COMPOUND or CB_COMPOUND was not cached, then the replier,

Further, since the parameters to SEQUENCE are different it is a false
retry according to this:

2.10.6.1.3.1.  False Retry

If a requester sent a Sequence operation with a slot ID and sequence
ID that are in the reply cache but the replier detected that the
retried request is not the same as the original request, including a
retry that has different operations or different arguments in the
operations from the original and a retry that uses a different
 principal in the RPC request's credential field that translates to a
different user, then this is a false retry.  When the replier detects
a false retry, it is permitted (but not always obligated) to return
NFS4ERR_SEQ_FALSE_RETRY in response to the Sequence operation when it
detects a false retry.

I'm not sure if the test should be fixed to either

1) allow either NFS4_OK or NFS4ERR_RETRY_UNCACHED_REP
2) just remove the test.

Thoughts?

