From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NFS4.1: Fix bug server don't reply the right
 fore_channel to client at create_session
Date: Wed, 5 Jan 2011 12:35:38 -0500
Message-ID: <20110105173537.GE13000@fieldses.org>
References: <4CDBBF7C.90108@cn.fujitsu.com>
 <20101112204554.GF32745@fieldses.org>
 <4CE0EB7B.5060509@cn.fujitsu.com>
 <20101229193551.GB12218@fieldses.org>
 <4D1BF99C.6030702@cn.fujitsu.com>
 <20110105010034.GB14744@fieldses.org>
 <4D240802.7050307@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFSv3 list <linux-nfs@vger.kernel.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47870 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752311Ab1AERfi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Jan 2011 12:35:38 -0500
In-Reply-To: <4D240802.7050307@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 05, 2011 at 01:56:18PM +0800, Mi Jinlong wrote:
> 
> 
> J. Bruce Fields:
> > On Thu, Dec 30, 2010 at 11:16:44AM +0800, Mi Jinlong wrote:
> >> Hi Bruce:
> >>
> >> J. Bruce Fields:
> >>> On Mon, Nov 15, 2010 at 04:12:43PM +0800, Mi Jinlong wrote:
> >>>> J. Bruce Fields:
> >>>>> On Thu, Nov 11, 2010 at 06:03:40PM +0800, Mi Jinlong wrote:
> >>>>>> At the latest kernel(2.6.37-rc1), server just initialize the forechannel
> >>>>>> at init_forechannel_attrs, but don't reflect it to reply.
> >>>>>>
> >>>>>> After initialize the session success, we should copy the forechannel info
> >>>>>> to nfsd4_create_session struct.
> >>>>> Thanks!
> >>>>>
> >>>>> Is there a chance you could write a pynfs test for this?
> >>>> Maybe the following one is OK.
> >>> Yes, thanks very much.  But could we use a larger MAX_SLOTS_PER_SESSION
> >>> value, to increase the chances this test will make sense for any
> >>> server?
> >>   Yes, but we can't use a huge value as 1000000 for that the test site
> >>   will allocate replay_cache for each fore_channel.maxrequests when get
> >>   the reply of CREATE_SESSION.
> > 
> > pynfs should only allocate enough for the returned maxrequests, right?
> 
>   Yes, it does like that. If server return a wrong maxrequests as 1000000, 
>   it will allocate 1000000 replay_cache. So we should set a small one here.

Thanks, I understand now.  Sure, let's go with your solution--applied.

--b.

> 
> > 
> >> If setting to 1000000 or more huger, 
> >>   when the test case fail, the test site will eat many memory. 
> >>
> >>   So, we should set it less than 1000 and add an explain.
> >>
> >>> Also, this is a "reply", not a "replay", test, so move it a little
> >>> later; how about the following?
> >>   Sorry for that, it's a typo. ^_^
> >>
> >>   Maybe we should set the TOO_MANY_SLOTS less than 1000, after testing,
> >>   the patch is as following:
> >>
> >>   Ps: delete the semicolon at the latest line.
> > 
> > Whoops, I obviously don't do much python....
> > 
> > --b.
> > 
> >> >From 2f544fcef0eef7ac1d59bc428be3436ad7d1bbde Mon Sep 17 00:00:00 2001
> >> From: Mi Jinlong <mijinlong@cn.fujitsu.com>
> >> Date: Wed, 29 Dec 2010 16:06:30 +0800
> >> Subject: [PATCH] SRVR: Can server return fore_channel maxreqs correctly
> >>
> >>     SRVR: Can server return fore_channel maxreqs correctly
> >>     
> >>     When client set the fore_channel maxreqs larger than server's
> >>     NFSD_MAX_SLOTS_PER_SESSION at create_session, the fore_channel
> >>     maxreqs at the reply must less than NFSD_MAX_SLOTS_PER_SESSION.
> >>     
> >>     At 2.6.37-rc1, the NFSD_MAX_SLOTS_PER_SESSION is 160.
> >>     
> >>     Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> >>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> >>
> >> ---
> >>  nfs4.1/server41tests/st_create_session.py |   19 +++++++++++++++++++
> >>  1 files changed, 19 insertions(+), 0 deletions(-)
> >>
> >> diff --git a/nfs4.1/server41tests/st_create_session.py b/nfs4.1/server41tests/st_create_session.py
> >> index 5f425d4..5cfac14 100644
> >> --- a/nfs4.1/server41tests/st_create_session.py
> >> +++ b/nfs4.1/server41tests/st_create_session.py
> >> @@ -363,3 +363,22 @@ def testCallbackVersion(t, env):
> >>                   (cb_occurred.low, cb_occurred.hi, cb_occurred.vers))
> >>      finally:
> >>          env.c1._check_version = orig
> >> +
> >> +def testMaxreqs(t, env):
> >> +    """A CREATE_SESSION with maxreqs too large should return
> >> +       a modified value
> >> +
> >> +    FLAGS: create_session all
> >> +    CODE: CSESS22
> >> +    """
> >> +    # Assuming this is too large for any server; increase if necessary:
> >> +    # but too huge will eat many memory for replay_cache, becareful it!
> >> +    TOO_MANY_SLOTS = 500
> >> +
> >> +    c = env.c1.new_client(env.testname(t))
> >> +    # CREATE_SESSION with fore_channel = TOO_MANY_SLOTS
> >> +    chan_attrs = channel_attrs4(0,8192,8192,8192,128, TOO_MANY_SLOTS, [])
> >> +    sess1 = c.create_session(fore_attrs=chan_attrs)
> >> +    if nfs4lib.test_equal(sess1.fore_channel.maxrequests,
> >> +                          chan_attrs.ca_maxrequests, "count4"):
> >> +        fail("Server allows surprisingly large fore_channel maxreqs")
> >> -- 
> >> 1.7.3.3
> >>
> > 
> 
> -- 
> ----
> thanks
> Mi Jinlong
> 
