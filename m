Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:34006 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754217AbaBFA62 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Feb 2014 19:58:28 -0500
Date: Thu, 6 Feb 2014 11:58:16 +1100
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
Message-ID: <20140206115816.544ff6f5@notabene.brown>
In-Reply-To: <20140205211107.GA14457@fieldses.org>
References: <20140130172451.7a354ce4@notabene.brown>
	<52F003A1.3060908@RedHat.com>
	<20140204093452.7b6d7c7d@notabene.brown>
	<52F130E2.6090308@RedHat.com>
	<20140205164351.7a766eff@notabene.brown>
	<20140205211107.GA14457@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/1OedsSqmc54aaCuaVEwVSjD"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/1OedsSqmc54aaCuaVEwVSjD
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 5 Feb 2014 16:11:07 -0500 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Wed, Feb 05, 2014 at 04:43:51PM +1100, NeilBrown wrote:
> > On Tue, 04 Feb 2014 13:26:42 -0500 Steve Dickson <SteveD@redhat.com> wr=
ote:
> >=20
> >=20
> > > >=20
> > > >>
> > > >> How would these daemons be restart and shutdown? Since this is a=20
> > > >> target, systemctl restart and system stop don't do anything.
> > > >=20
> > > > This is something I haven't completely figured out yet.
> > > >=20
> > > > Part of the solution might be the "PartOf" directive.
> > > > If each service claims to be "PartOf" the main one, then stopping or
> > > > restarting the main service will propagate to stopping and restarti=
ng the
> > > > individual services.
> > > > Unfortunately in nfs we have some shared services.  rpc.statd and r=
pc.gssd
> > > > are needed by both server and client.  That isn't a big problem for=
 'restart',
> > > > but if you 'systemctl stop nfs-client' and find that the server isn=
't
> > > > properly working any more, that would be awkward
> > > > If could possibly work around that by setting "StopWhenUnneeded" fo=
r those
> > > > shared services.  Then e.g. rpc.statd would stop when both client a=
nd server
> > > > are stopped, but not if either one of them is stopped.
> > > > However I don't know how that interacts with restart.  I suspect th=
at the
> > > > StopWhenUnneeded services are *not* stopped and restarted when the =
main
> > > > service is stopped.  So it would  be  hard to restart all nfs servi=
ces on an
> > > > upgrade.
> > > >=20
> > > > Further research seems needed here.
> > > Fine... I'll try to digest what you are saying here, but
> > > would it make it easier if everything was in a service file?
> >=20
> > So I did a bit more research and thinking, and I present the two patches
> > below for consideration.  If you agree and would prefer them in separate
> > emails I can certainly do that.
> >=20
> > The first ensures that we can easily restart all daemons during software
> > update.  It creates a new 'nfs-utils.service' which exists only to allo=
w that
> > restart.
> >=20
> > The second ensures startup and shutdown work properly (though I haven't
> > tested much).
> > Do we need to shutdown nfs-server or nfs-client easily at any time othe=
r than
> > system shutdown?
>=20
> I think it's hard to as I don't think there's a way for the NSM protocol
> to treat the nfs client and server as different things that could go up
> and down independently.  But I could be wrong, I rarely think about
> statd!  In a v4-only setup that wouldn't be a problem any more.

So if we don't make it particular easy to restart statd, then that might be=
 a
good thing?  I can live with that :-)

>=20
> On the server side there are a few parameters (v4 lease time?) that can
> only be changed with a restart but maybe that's not terribly important.

Maybe this should be treated as 'reload'.  If we provide ExecReload for
nfs-server.service which:
 - stops the nfsd threads
 - updates all these parameters
 - optionally triggers a new grace period?? (or is that automatic)
 - start the nfsd threads

we could document that  "systemctl reload nfs-server" does the right thing

>=20
> HA people may restart the server on failover to get a new grace period.
> They probably use their own scripts for that but it would be better to
> get them using standard systemd configuration to the extent possible.

Probably best not to second-guess such configurations if we don't thoroughly
understand them - but if we hear of a need that our unit files don't meant =
we
can use that as a trigger for improvement.

>=20
> Anyway those are existing problems that it's not necessarily up to you
> to fix.

True, but good to consider nonetheless.
Thanks,
NeilBrown

--Sig_/1OedsSqmc54aaCuaVEwVSjD
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUvLeKDnsnt1WYoG5AQI14Q//aFl+R0WFudbTzGEQ9qTohJjVUpitst1d
2K8qjr6B9k4wsf0gagCRNNRS51o2ZxltC3nslVTBWf4zGoz/08+YuTozYhZjCiq6
b2zoz+N9XSrF1u+JBUIv2qaOdSZkZV3vz8bundm9hgANHphj/CtD9Eh8GZW0u7D3
fNGKhI1+S+I5V/fyEbPDFu0Eh4rnxZYWNN2LvVt8xzTRamqXmRGeVTs0+kkacLLU
DRkNUap0mmqMTxpXOEdoF1BkhOFoX4201sgCSr9DDyHMgELVQObrsZkDdcYgHv1H
YIO0fKR3F9Z/hWzXd7opzcbcKQzzPrm+3QPxXXp0YdrXNGjM3xjr3VWRmHW697oq
Tik1mgRmiSdru916DHNxfDl+JU5G36vHnDUTaeahMtoCgbijQPyaQ3NSs88b9Wmx
5x0vfI9+pNXT4PKBiddBdbzq8UrPqIuMkIr/mi+3Vm50yD9tI2W8Phg3tz2T0OiC
/vH/svefQIcN46+RDUGMwUP7jILr/ftexGcJ4e7/fpT77UCX+lfeI5TxZWtvYuX5
GCQDbwgyfd1oMeisThqwtt76RbYlqMEhn2U9AOcGKn07ofemlUiGwlI3LTN7JiU3
x4ws4mWDrq+P0ASGDEWr2iUwJKYKgPx3xK2WOV8rhSkZke2ILl/assbBWg8ii+66
OhXzXVNujMI=
=apBY
-----END PGP SIGNATURE-----

--Sig_/1OedsSqmc54aaCuaVEwVSjD--
