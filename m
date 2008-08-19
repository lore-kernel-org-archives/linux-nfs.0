From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH]lockd: fix handling of grace period after long periods
	of inactivity
Date: Tue, 19 Aug 2008 18:12:09 -0400
Message-ID: <20080819221209.GF8331@fieldses.org>
References: <48A41220.8030203@oss.ntt.co.jp> <20080814190652.GE23859@fieldses.org> <1218763945.5291.19.camel@sebastian.kern.oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: NAKANO Hiroaki <nakano.hiroaki-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>,
	Trond.Myklebust@netapp.com, neilb@suse.de,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Fernando Luis =?utf-8?Q?V=C3=A1zquez?= Cao
	<fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:50012 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753189AbYHSWMO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Aug 2008 18:12:14 -0400
In-Reply-To: <1218763945.5291.19.camel-xpvPi5bcW5X5OjGIXfuPlhrrLbDL3r4M6qtp775pBPw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 15, 2008 at 10:32:25AM +0900, Fernando Luis V=C3=A1zquez Ca=
o wrote:
> Hi Bruce!
>=20
> On Thu, 2008-08-14 at 15:06 -0400, J. Bruce Fields wrote:
> > On Thu, Aug 14, 2008 at 08:08:16PM +0900, NAKANO Hiroaki wrote:
> > > lockd uses time_before() to determine whether the grace period ha=
s
> > > expired. This would seem to be enough to avoid timer wrap-around =
issues,
> > > but, unfortunately, that is not the case. The time_* family of
> > > comparison functions can be safely used to compare jiffies relati=
vely
> > > close in time, but they stop working after approximately LONG_MAX=
/2
> > > ticks. nfsd can suffer this problem because the time_before() com=
parison
> > > in lockd() is not performed until the first request comes in, whi=
ch
> > > means that if there is no lockd traffic for more than LONG_MAX/2 =
ticks
> > > we are screwed.
> > >=20
> > > The implication of this is that once time_before() starts misbeha=
ving
> > > any attempt from a NFS client to execute fcntl() will be received=
 with a
> > > NLM_LCK_DENIED_GRACE_PERIOD message for 25 days (assuming HZ=3D10=
00). In
> > > other words, the 50 seconds grace period could turn into a grace =
period
> > > of 50 days or more.
> > >=20
> > > This patch corrects this behavior by implementing grace period wi=
th a
> > > (retriggerable) timer.
> > >=20
> > > Note: This bug was analyzed independently by Oda-san <oda@valinux=
=2Eco.jp>
> > > and myself.
> >=20
> > Good catch!  Did you actually run across this in practice?  I would=
've
> > thought it relatively unusual to have a lockd that didn't receive i=
ts
> > first lock request until 25 days after startup.
> Yes, we did find this problem in production. More often than one woul=
d
> wish, installing new software in a system that has been running witho=
ut
> a hiccup for weeks or months is the only thing you will need to bring
> mayhem.
>=20
> > I still have a mild preference for a work struct just in case we en=
d up
> > wanting to do something slightly more complicated to end the grace
> > period, but I don't really have anything in mind.
> For simplicity I think we could we get Nakano-san's patch merged firs=
t.
> If needed, moving to a work-based solution should be relatively easil=
y.

There's no real difference; patches I've been planning on submitting fo=
r
2.6.28 follow.

(We could submit a patch for 2.6.27, since it's a bugfix, but this isn'=
t
a new regression, so existing users at least won't be made any worse
off, and this doesn't crash the server, or anything similarly drastic.
It's still serious, just not quite serious enough to submit at this
point in the release cycle, as I understand the rules....)

--b.
