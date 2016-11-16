Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:49882 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753186AbcKPEAv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 15 Nov 2016 23:00:51 -0500
From: NeilBrown <neilb@suse.com>
To: Chuck Lever <chuck.lever@oracle.com>
Date: Wed, 16 Nov 2016 15:00:42 +1100
Cc: Jeff Layton <jlayton@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Question about nfsdcltrack --storagedir
In-Reply-To: <B7F56198-AA01-453B-A6ED-407B8D266724@oracle.com>
References: <87k2cdmi26.fsf@notabene.neil.brown.name> <1478692626.2394.9.camel@redhat.com> <877f8c9pku.fsf@notabene.neil.brown.name> <1478739358.2442.1.camel@redhat.com> <8B417571-FAA9-4793-AE5F-F71BCDF7ADD5@oracle.com> <87oa1nklug.fsf@notabene.neil.brown.name> <B7F56198-AA01-453B-A6ED-407B8D266724@oracle.com>
Message-ID: <8737ishy51.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, Nov 12 2016, Chuck Lever wrote:

> Hiya Neil-
>
>> On Nov 10, 2016, at 5:32 PM, NeilBrown <neilb@suse.com> wrote:
>>=20
>> On Fri, Nov 11 2016, Chuck Lever wrote:
>>=20
>>>>=20
>>>> No objection here, especially if we make it so that we have existing
>>>> behavior when there is no config file. nfs-utils even has some config
>>>> file parsing routines now in support/nfs that should be sufficient.
>>>=20
>>> Just a general thought:
>>>=20
>>> It's fine to store the configuration data under /etc, but for new
>>> administrative interfaces, please create a command line UI which
>>> is used to edit said configuration data. This makes it much easier
>>> for users to script administrative changes, to build GUIs around,
>>> and for our Q/A teams to construct automated tests.
>>=20
>> If that is an important concern (and I don't disagree) then I would
>> suggest dropping the idea of a config file with sections and just have a
>> file with simple (case sensitive) "name=3Dvalue" assignments.
>
> I'm not necessarily advocating this, but we already have a single
> central key-value file that stores NFS configuration information
> (at least on RH-based distros), and that's /etc/sysconfig/nfs.

SUSE also has /etc/sysconfig/nfs, but with different names having
different meanings.

Debian has /etc/default/nfs_common, again with different names.

>
>
>> Then sed
>> can be used to modify the file.
>>=20
>> Or.... just use git to modify the config file.
>>=20
>>  sudo git config --file /etc/idmapd.conf mapping.nobody-user neilb
>>=20
>> did what I expected it to do :-)
>
> Clever! But to be a little more clear, this is not about the
> technology used to modify a config file.
>
> After an administrator finds and modifies the correct file, there's
> a set of dodgy distribution-dependent instructions to figure out what
> daemons need to be poked with a sharp stick to pick up the new config.
>
> For idmapd.conf changes, for example, it's going to be a different
> set of pokes depending on whether its server or client.
>
> A kernel cache has to be invalidated in some important cases. This
> is true for modifying things related to the FH or export cache, and
> that is already wrapped in an administrative CLI: exportfs.
>
> For gssd, Bruce recently showed me a series of (as far as I know,
> undocumented) systemctl commands that are needed to pick up changes
> to gssd command line options on RHEL 7.

Ahh, I understand your concern better now I think.

I would hope that "systemctl restart nfs-utils" would do everything
needed to make sure all config changes are effective.  That was
certainly the intention.

This may be a little heavy-handed (killing and restarting, rather than
just reloading config) but all the state lost should be refillable
caches so I don't think it should be a problem.

The questions is: does this command really do all that is needed?
If not, it should be fixed.

>
> If I had a lot of time to explore this, my strategy would be:
>
> a) Provide one or a few well-known tools to edit NFS config files
>
> b) Mechanize the acts of putting said edits into effect, and integrate
> those mechanisms into the tools
>
> c) Tie the tools directly to documentation (--help or a man page)

I'm not at all convinced about the need for an editing tool but I do
agree that documentation would be a big help.  I imagine a "nfs.systemd"
man page (or maybe "systemd.nfs", but that would cause arguments about
ownership of the namespace) which set out which services should be
enabled or masked or restarted to provide which outcomes.
>
> If there was a library that managed this for us, open-coded config
> file parsing for nfsmount.conf and for idmapd.conf in nfs-utils
> could be replaced.

It already was.  support/nfs/conffile.c is used by both mount and
idmapd.
e.g.
		conf_init();
		verbose =3D conf_get_num("General", "Verbosity", 0);
		cache_entry_expiration =3D conf_get_num("General",
				"Cache-Expiration", DEFAULT_IDMAP_CACHE_EXPIRY);
		CONF_SAVE(xpipefsdir, conf_get_str("General", "Pipefs-Directory"));
		if (xpipefsdir !=3D NULL)
			strlcpy(pipefsdir, xpipefsdir, sizeof(pipefsdir));
		CONF_SAVE(nobodyuser, conf_get_str("Mapping", "Nobody-User"));
		CONF_SAVE(nobodygroup, conf_get_str("Mapping", "Nobody-Group"));

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYK9nqAAoJEDnsnt1WYoG5SEsP/0kwm9OUzXOVB0LBqsvGxaL7
/NzJfgjWyWyHw/4RtAjFQ69trMLGD5dvJAWE0zTwFINWubxUVWNqmSMr1lGALPlV
/822iUckItvjs4Nc3uA9uEm3koESSqRQK+1BQNlj2F4gtuwinKRPv1lDieh3ehea
SO6RhVn++cNPyNZJss/Vmy1fd59C0xOxQoCgQB+wr/fKlAILs4a2q8ZR3lw16jV9
/pUfGj0enrQrVhEeDty9ZTDdN7cVr7pnmrFfIcuSAWpA57Qku3ORbSGVNVGqDNLv
4UfjKbiS31MUpSuV+MfAFNILzx1P6nysTeLsMpl6NBNlpXj9x9DpH8qxyQDdKIu1
voVVDsGk020G6QMN1gB15gjtPtPzucsNcNRy7NtwkySXiNm/3faAwdsV+s6s6f3O
rk6v4SugGrBdOkpBN4jzr3eD+d7k3UuYzRnHPDSvgWMXFZazvW3GT0YzArce364B
/ZgzPDH6pf0oAjb71ERpSslRLJXsqY6SP6qRaaW0TtB7ci1Q3f1PbnOfectBlzXA
iOk68OF6tj6eUfG+Zf3ziXwZbh869IdKFC6cPACSbPsprOSGrq/2Y86hlQfZi+iY
Prmr3nKEGY64VWrSKpNE3ZsVnf9q6sLYAccPLtT0YDD9+K6XxZipqWtXwaBGX4Pg
dcpj07LFylhdCDek4y4G
=24mB
-----END PGP SIGNATURE-----
--=-=-=--
