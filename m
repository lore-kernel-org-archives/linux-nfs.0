Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:49522 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756028AbcKJWSG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 10 Nov 2016 17:18:06 -0500
From: NeilBrown <neilb@suse.com>
To: Jeff Layton <jlayton@redhat.com>
Date: Fri, 11 Nov 2016 09:17:59 +1100
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH/RFC nfs-utils] nfsdcltrack: read configuration from a file
In-Reply-To: <1478790053.2402.5.camel@redhat.com>
References: <87k2cdmi26.fsf@notabene.neil.brown.name> <1478692626.2394.9.camel@redhat.com> <877f8c9pku.fsf@notabene.neil.brown.name> <1478739358.2442.1.camel@redhat.com> <8737j0lyms.fsf@notabene.neil.brown.name> <1478790053.2402.5.camel@redhat.com>
Message-ID: <87r36jkmi0.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Nov 11 2016, Jeff Layton wrote:

> On Thu, 2016-11-10 at 15:58 +1100, NeilBrown wrote:
>> As nfsdcltrack is normally run directly from the kernel
>> there is no opportunity to change the default
>> storage directory.  This can be useful in a cluster to
>> locate the "storage directory" on shared storage.
>>=20
>> The easiest alternative is to allow configuration to be read from a
>> file, particularly as nfs-utils already has code for parsing a config fi=
le.
>>=20
>> So read the config file "/etc/nfs.conf" (or as set by ./configure) and
>> look for "storagedir" and "debug" in the "nfsdcltrack" section.
>> These values can still be over-ridden by command line options.
>>=20
>> A generic name (nfs.conf) was changes for the config file so that
>> other daemons can be enhanced to read configuration from there.
>> This may be easier than passing command line arguments through systemd.
>>=20
> I like the basic idea, but I'm not so sure we want to use a generic
> config file like this. What else do you envision using this file?

See https://lwn.net/Articles/584373/ and surrounds (included where I
said that I wouldn't be providing patches:-).

I'm not happy with current mechanisms for passing configuration from a
configurator gui, through systemd, to various daemons.  Having a common
config file, rather having to stitch together command-line args, feels
like it might be a step in the right direction.  Given that I was adding
a config file, I thought that leaving it open-ended might be a good
idea.

We already have /etc/nfsmount.conf and /etc/idmapd.conf.
How many more do we want?
I note that that idmapd.conf contains Pipefs-Directory.  Various
other daemons need to know where that is.  Wouldn't it be nice if they
all read the one config file?

I haven't resolved in my mind where the "impedance matching" should
happen.  To explain:
Different distros put their configuration in different places
(/etc/sysconfig/nfs /etc/defaults/nfs) and use different names for the
same value.  These files are all "name=3Dval" files, without the [section]
headings of conf files.
What is the best way to get the config from there to the local variables
inside the various programs?

Currently a systemd service runs a script which reads the configuration
file and writes out an environment file for systemd to read, which
provides command-line args for each daemon.  I'd rather something more
direct.

If the parsing of /etc/nfs.conf allowed
  name=3D$var
to extract 'var' from the environment, then (almost) each distro
could have a static /etc/nfs.conf which listed which configuration
variables affected which settings.  Then systemd could read the
original configuration file to set up the environment, then each tool
would read /etc/nfs.conf to extract the desired parts of the environment.

Except that wouldn't work for nfsdcltrack as we cannot easily control
it's environment.  And there would probably be other things that didn't
quite work right.

Maybe the best thing is for the configurator-gui to be required to run
some post-processing thing which creates /etc/nfs.conf.
Then of course, it could just create systemd drop-in files which
created all the required arguments - then tells systemd to re-read those
files.  So maybe this is only useful for programs that aren't run via
systemd.

I'm as yet far from certain as to what I want, but keeping things
extensible seems like a generally good principle.

>
> That said, if we are going to do this, we should probably make it clear
> that it's for server-side configuration. Maybe "nfsd.conf" or
> "nfs-server.conf" would be a better name?

Why only server-side?  rpc-gssd needs configuration too.  It and
svcgssd (where used) are needed on both server and client (for
NFSv4.0).

Thanks,
NeilBrown

>
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>  configure.ac                      |  7 +++++++
>>  utils/nfsdcltrack/nfsdcltrack.c   | 12 ++++++++++++
>>  utils/nfsdcltrack/nfsdcltrack.man | 14 ++++++++++++++
>>  3 files changed, 33 insertions(+)
>>=20
>> diff --git a/configure.ac b/configure.ac
>> index d60f3a2f7efa..8a5aa2e5203b 100644
>> --- a/configure.ac
>> +++ b/configure.ac
>> @@ -24,6 +24,12 @@ AC_ARG_WITH(statedir,
>>  	statedir=3D$withval,
>>  	statedir=3D/var/lib/nfs)
>>  	AC_SUBST(statedir)
>> +AC_ARG_WITH(nfsconfig,
>> +	[AC_HELP_STRING([--with-nfsconfig=3D/config/file],
>> +			[use general config file /config/file @<:@default=3D/etc/nfs.conf@:>=
@])],
>> +	nfsconfig=3D$withval,
>> +	nfsconfig=3D/etc/nfs.conf)
>> +	AC_SUBST(nfsconfig)
>>  AC_ARG_WITH(statdpath,
>>  	[AC_HELP_STRING([--with-statdpath=3D/foo],
>>  			[define the statd state dir as /foo instead of the NFS statedir @<:@=
default=3D/var/lib/nfs@:>@])],
>> @@ -468,6 +474,7 @@ dnl Export some path names to config.h
>>  dnl *************************************************************
>>  AC_DEFINE_UNQUOTED(NFS_STATEDIR, "$statedir", [This defines the locatio=
n of the NFS state files. Warning: this must match definitions in config.mk=
!])
>>  AC_DEFINE_UNQUOTED(NSM_DEFAULT_STATEDIR, "$statdpath", [Define this to =
the pathname where statd keeps its state file])
>> +AC_DEFINE_UNQUOTED(NFS_CONFFILE, "$nfsconfig", [This defines the locati=
on of NFS daemon config file])
>>=20=20
>>  if test "x$cross_compiling" =3D "xno"; then
>>  	CFLAGS_FOR_BUILD=3D${CFLAGS_FOR_BUILD-"$CFLAGS"}
>> diff --git a/utils/nfsdcltrack/nfsdcltrack.c b/utils/nfsdcltrack/nfsdclt=
rack.c
>> index fcdda7f66b8b..e6e514b78316 100644
>> --- a/utils/nfsdcltrack/nfsdcltrack.c
>> +++ b/utils/nfsdcltrack/nfsdcltrack.c
>> @@ -43,6 +43,7 @@
>>  #include <sys/capability.h>
>>  #endif
>>=20=20
>> +#include "conffile.h"
>>  #include "xlog.h"
>>  #include "sqlite.h"
>>=20=20
>> @@ -55,6 +56,8 @@
>>  /* defined by RFC 3530 */
>>  #define NFS4_OPAQUE_LIMIT	1024
>>=20=20
>> +char *conf_path =3D NFS_CONFFILE;
>> +
>>  /* private data structures */
>>  struct cltrack_cmd {
>>  	char *name;
>> @@ -553,6 +556,7 @@ int
>>  main(int argc, char **argv)
>>  {
>>  	char arg;
>> +	char *val;
>>  	int rc =3D 0;
>>  	char *progname, *cmdarg =3D NULL;
>>  	struct cltrack_cmd *cmd;
>> @@ -562,6 +566,14 @@ main(int argc, char **argv)
>>  	xlog_syslog(1);
>>  	xlog_stderr(0);
>>=20=20
>> +	conf_init();
>> +	val =3D conf_get_str("nfsdcltrack", "storagedir");
>> +	if (val)
>> +		storagedir =3D val;
>> +	rc =3D conf_get_num("nfsdcltrack", "debug", 0);
>> +	if (rc > 0)
>> +		xlog_config(D_ALL, 1);
>> +
>>  	/* process command-line options */
>>  	while ((arg =3D getopt_long(argc, argv, "hdfs:", longopts,
>>  				  NULL)) !=3D EOF) {
>> diff --git a/utils/nfsdcltrack/nfsdcltrack.man b/utils/nfsdcltrack/nfsdc=
ltrack.man
>> index 4b8f4d762a00..cc24b7a2c32e 100644
>> --- a/utils/nfsdcltrack/nfsdcltrack.man
>> +++ b/utils/nfsdcltrack/nfsdcltrack.man
>> @@ -67,6 +67,20 @@ Check to see if a nfs_client_id4 is allowed to reclai=
m. This command requires a
>>  .IP "\fBgracedone\fR" 4
>>  .IX Item "gracedone"
>>  Remove any unreclaimed client records from the database. This command r=
equires a epoch boot time as an argument.
>> +.SH "EXTERNAL CONFIGURATION"
>> +The directory for stable storage information can be set via the file
>> +.B /etc/nfs.conf
>> +by setting the
>> +.B storagedir
>> +value in the
>> +.B nfsdcltrack
>> +section.  For example:
>> +.in +5
>> +[nfsdcltrack]
>> +.br
>> +  storagedir =3D /shared/nfs/nfsdcltrack
>> +.in -5
>> +Debuging to syslog can also be enabled by setting "debug =3D 1" in this=
 file.
>>  .SH "LEGACY TRANSITION MECHANISM"
>>  .IX Header "LEGACY TRANSITION MECHANISM"
>>  The Linux kernel NFSv4 server has historically tracked this information
>
> --=20
> Jeff Layton <jlayton@redhat.com>

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYJPIXAAoJEDnsnt1WYoG5FLAQALVFBQULd/rB8KHlaGaXmhQR
FIJDuuouWaqPxZ+bKUFRTpYx/m9/ZEe6d60khUQy6BbCIKU+csRoLWHkyJ0Sv1+k
7W+9BaAG7U6agaCz2Ib2zdSWePvzhoZTrZbXnZCXFHT4eT+DCML+0UOV9XZrlBno
90+v6yUujW7kbsf0kT7mPfMUPATGTFZxHOwp9e6jy8ZqRe8YO/+HCYpF+397uGJ8
m7JzASM0V+vnxoXv1ao2P3dqHqBxW6IjNg6X2R1Z+sz303452sSpzocbRNOPDhow
vch4nZWMptRLvGD8l5DxCHNIwV5HDm8CJQ6svsirx9f0DGhGVHMaYNn0WOmoSX3Z
uokAceBR8e18qmG1WVWGjPvNrD9Uqv9z/j5YAwF5pLfln9qAIJ/8PXn9eqNtZLP9
BnTgm7sCs9hY1YzpSJMn7i9tozm3BE/np6lMxlvXe7XDQOEDy25fPRTfhIYpcrr4
xRFLidgH6HM7n5A7mLYqnIjqcK+VY6JFblrcuggRuTxVxrEmWOfNzCPC0HTi5QfD
ll1rgV9rBcaLQCqWUgU91Uwp4RWXMY76YAc3SJEvxccMIpr2ucCLH/REyD9qSNC0
m+DDtX/jMaObuNN2s23h7hFhNcMZZ3wHLCHfSHOQ6T54XPDwQnOTR0M/YsTj5qd3
ZTewW83TRvXvkUIOuYYV
=zWdZ
-----END PGP SIGNATURE-----
--=-=-=--
