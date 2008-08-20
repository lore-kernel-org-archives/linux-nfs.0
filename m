From: Fernando Luis =?ISO-8859-1?Q?V=E1zquez?= Cao
	<fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH]lockd: fix handling of grace period after long periods
	of inactivity
Date: Wed, 20 Aug 2008 10:31:19 +0900
Message-ID: <1219195879.17077.36.camel@sebastian.kern.oss.ntt.co.jp>
References: <48A41220.8030203@oss.ntt.co.jp>
	 <20080814190652.GE23859@fieldses.org>
	 <1218763945.5291.19.camel@sebastian.kern.oss.ntt.co.jp>
	 <20080819221209.GF8331@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: NAKANO Hiroaki <nakano.hiroaki-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>,
	Trond.Myklebust@netapp.com, neilb@suse.de,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from serv2.oss.ntt.co.jp ([222.151.198.100]:56794 "EHLO
	serv2.oss.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174AbYHTBbV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Aug 2008 21:31:21 -0400
In-Reply-To: <20080819221209.GF8331@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-08-19 at 18:12 -0400, J. Bruce Fields wrote:
> On Fri, Aug 15, 2008 at 10:32:25AM +0900, Fernando Luis V=C3=A1zquez =
Cao wrote:
> > Hi Bruce!
> >=20
> > On Thu, 2008-08-14 at 15:06 -0400, J. Bruce Fields wrote:
> > > On Thu, Aug 14, 2008 at 08:08:16PM +0900, NAKANO Hiroaki wrote:
> > > > lockd uses time_before() to determine whether the grace period =
has
> > > > expired. This would seem to be enough to avoid timer wrap-aroun=
d issues,
> > > > but, unfortunately, that is not the case. The time_* family of
> > > > comparison functions can be safely used to compare jiffies rela=
tively
> > > > close in time, but they stop working after approximately LONG_M=
AX/2
> > > > ticks. nfsd can suffer this problem because the time_before() c=
omparison
> > > > in lockd() is not performed until the first request comes in, w=
hich
> > > > means that if there is no lockd traffic for more than LONG_MAX/=
2 ticks
> > > > we are screwed.
> > > >=20
> > > > The implication of this is that once time_before() starts misbe=
having
> > > > any attempt from a NFS client to execute fcntl() will be receiv=
ed with a
> > > > NLM_LCK_DENIED_GRACE_PERIOD message for 25 days (assuming HZ=3D=
1000). In
> > > > other words, the 50 seconds grace period could turn into a grac=
e period
> > > > of 50 days or more.
> > > >=20
> > > > This patch corrects this behavior by implementing grace period =
with a
> > > > (retriggerable) timer.
> > > >=20
> > > > Note: This bug was analyzed independently by Oda-san <oda@valin=
ux.co.jp>
> > > > and myself.
> > >=20
> > > Good catch!  Did you actually run across this in practice?  I wou=
ld've
> > > thought it relatively unusual to have a lockd that didn't receive=
 its
> > > first lock request until 25 days after startup.
> > Yes, we did find this problem in production. More often than one wo=
uld
> > wish, installing new software in a system that has been running wit=
hout
> > a hiccup for weeks or months is the only thing you will need to bri=
ng
> > mayhem.
> >=20
> > > I still have a mild preference for a work struct just in case we =
end up
> > > wanting to do something slightly more complicated to end the grac=
e
> > > period, but I don't really have anything in mind.
> > For simplicity I think we could we get Nakano-san's patch merged fi=
rst.
> > If needed, moving to a work-based solution should be relatively eas=
ily.
>=20
> There's no real difference; patches I've been planning on submitting =
for
> 2.6.28 follow.
Yes, both approaches are essentially the same.

> patches I've been planning on submitting for 2.6.28 follow.
Thanks!

> (We could submit a patch for 2.6.27, since it's a bugfix, but this is=
n't
> a new regression, so existing users at least won't be made any worse
> off, and this doesn't crash the server, or anything similarly drastic=
=2E
> It's still serious, just not quite serious enough to submit at this
> point in the release cycle, as I understand the rules....)
My only concern is that even though the server will not crash we may ge=
t
seemingly hanged processes on the client side (the reason being that th=
e
client will be receiving only NLM_LCK_DENIED_GRACE_PERIOD messages
during the whole "extended" grace period). It might be worth getting it
merged before 2.6.27 comes out and distros start using it.

 - Fernando

