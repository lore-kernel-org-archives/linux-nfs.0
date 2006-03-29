From: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
Subject: Re: timeo & retrans, smaller max timeout than 60 seconds?
Date: Wed, 29 Mar 2006 22:24:15 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0603292058050.15464@maggie.lkpg.cendio.se>
References: <Pine.LNX.4.64.0603290921500.2597@maggie.lkpg.cendio.se>
 <1143641272.7928.13.camel@lade.trondhjem.org>
 <Pine.LNX.4.64.0603291625370.7796@maggie.lkpg.cendio.se>
 <1143644879.7928.44.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-1950218555-1143659236=:15464"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FOhDP-0005nq-Mi
	for nfs@lists.sourceforge.net; Wed, 29 Mar 2006 12:24:27 -0800
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FOhDO-0002g7-0U
	for nfs@lists.sourceforge.net; Wed, 29 Mar 2006 12:24:27 -0800
Received: from maggie.lkpg.cendio.se (maggie.lkpg.cendio.se [10.47.1.208])
	by mail.cendio.se (Postfix) with ESMTP id DE55D25DB23
	for <nfs@lists.sourceforge.net>; Wed, 29 Mar 2006 22:24:15 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <1143644879.7928.44.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-1950218555-1143659236=:15464
Content-Type: TEXT/PLAIN; CHARSET=iso-8859-1; format=flowed
Content-ID: <Pine.LNX.4.64.0603292107421.15464@maggie.lkpg.cendio.se>
Content-Transfer-Encoding: quoted-printable

On Wed, 29 Mar 2006, Trond Myklebust wrote:

>>> The maximum timeout for TCP is 600 seconds, i.e. 10 minutes.
>>
>> Does this mean that the manpage statement "The maximum timeout is alwa=
ys
>> 60 seconds." is incorrect?
>
> Yes.

Let's fix this, then. What about this patch, against=20
util-linux-2.13-pre7 ?:

--- ./mount/nfs.5.org   2006-03-29 20:54:59.000000000 +0200
+++ ./mount/nfs.5       2006-03-29 20:57:35.000000000 +0200
@@ -43,12 +43,12 @@
  first retransmission after an RPC timeout.
  The default value is 7 tenths of a second.  After the first timeout,
  the timeout is doubled after each successive timeout until a maximum
-timeout of 60 seconds is reached or the enough retransmissions
+timeout is reached or the enough retransmissions
  have occured to cause a major timeout.  Then, if the filesystem
  is hard mounted, each new timeout cascade restarts at twice the
  initial value of the previous cascade, again doubling at each
-retransmission.  The maximum timeout is always 60 seconds.
-Better overall performance may be achieved by increasing the
+retransmission.  The maximum timeout is 60 seconds for UDP and 600
+seconds for TCP. Better overall performance may be achieved by increasin=
g=20
the
  timeout when mounting on a busy network, to a slow server, or through
  several routers or gateways.
  .TP 1.5i


>>>>    If we start using, say, retrans=3D1, does this mean that applicat=
ions can
>>>>    recieve EIO after as little as 1 second?
>>>
>>> No. "timeo" controls the timeout value. "retrans" controls the number=
 of
>>> retransmissions before a major timeout is declared.
>>
>> Yes, but the manpage states that EIO is reported when a major timeout
>> occurs. So, the time until EIO must be influenced by "retrans", right?
>
> It is influenced by _both_. timeo sets the timeout value for a single
> retransmission. retrans sets the number of retransmissions in a major
> timeout.

Ok, so with the default values of timeo=3D7 and retrans=3D3, the first ma=
jor=20
timeout will occur after 0.7 + 1.4 + 2.8 =3D 4.9 seconds? And with soft=20
mounts, this should return EIO to the application?

In that case, how is it possible that I experience timeouts of 180=20
seconds?!?


>>>> * Is it true that all the "-f" option to umount does is skip trying
>>>>    MOUNTPROC_UMNT?
>>>
>>> No. '-f' causes all pending RPC calls to be cancelled (and return -EI=
O).
>>
>> Is MOUNTPROC_UMNT tried even when -f is specified?
>
> I believe so.

You are right. I've checked the source now. umount always calls=20
MOUNTPROC_UMNT, using a hardcoded timeout of 20 seconds. I'm including a=20
patch below that adds an option for controlling this timeout. Comments?

(mount uses a hardcoded timeout of 20 seconds as well in fg mode, even th=
e=20
manpage says the retry parameter is valid both for fg and bg mode. I'm no=
t=20
sure if it's the doc or the source that's incorrect. In any case, I think=
=20
it's sad that the retry parameter uses *minutes* rather than seconds. Har=
d=20
to fix, without breaking backwards compatibility.)


>>>> * About "intr": The man page says "If an NFS file operation has a ma=
jor
>>>>    timeout and it is hard mounted". Does "intr" affect soft mounts i=
n any
>>>>    way, or is it better to remove it?
>>>
>>> Intr changes the set of signals that are able to interrupt an RPC cal=
l.
>>> It has nothing to do with "soft".
>>
>> That is - it has no effect when "soft" is used?
>
> No. I mean that it has the same effect whether you use "soft" or "hard"=
.
> Intr controls signals, not timeouts.

Then again the man page wording is strange:

"If an NFS file operation has a major timeout and it is hard mounted,"

Shouldn't this read:

"If an NFS file operation has a major timeout,"

?

Regards,
Peter =C5strand

Patch that adds a timeout option to umount:

diff -bur util-linux-2.13-pre7.org/mount/umount.8 util-linux-2.13-pre7/mo=
unt/umount.8
--- util-linux-2.13-pre7.org/mount/umount.8	2004-11-10 20:49:37.000000000=
 +0100
+++ util-linux-2.13-pre7/mount/umount.8	2006-03-29 22:13:05.000000000 +02=
00
@@ -111,6 +111,9 @@
  and cleanup all references to the filesystem as soon as it is not busy
  anymore.
  (Requires kernel 2.4.11 or later.)
+.TP
+.BI \-T " timeout"
+Indicates the timeout to use for NFS operations.

  .SH "THE LOOP DEVICE"
  The
diff -bur util-linux-2.13-pre7.org/mount/umount.c util-linux-2.13-pre7/mo=
unt/umount.c
--- util-linux-2.13-pre7.org/mount/umount.c	2005-09-23 21:55:55.000000000=
 +0200
+++ util-linux-2.13-pre7/mount/umount.c	2006-03-29 21:48:21.000000000 +02=
00
@@ -88,6 +88,9 @@
  /* True if ruid !=3D euid.  */
  int suid =3D 0;

+/* Timeout for NFS operations */
+int timeout =3D 20;
+
  /*
   * check_special_umountprog()
   *	If there is a special umount program for this type, exec it.
@@ -201,7 +204,7 @@

        saddr.sin_family =3D AF_INET;
        saddr.sin_port =3D htons(port);
-      pertry.tv_sec =3D 3;
+      pertry.tv_sec =3D timeout;
        pertry.tv_usec =3D 0;
        if (opts && (p =3D strstr(opts, "tcp"))) {
  	   /* possibly: make sure option is not "notcp"
@@ -219,7 +222,7 @@
  	   }
        }
        clp->cl_auth =3D authunix_create_default();
-      try.tv_sec =3D 20;
+      try.tv_sec =3D timeout;
        try.tv_usec =3D 0;
        clnt_stat =3D clnt_call(clp, MOUNTPROC_UMNT,
  			    (xdrproc_t) xdr_dir, dirname,
@@ -493,8 +496,8 @@
  usage (FILE *fp, int n)
  {
    fprintf (fp, _("Usage: umount [-hV]\n"
-	       "       umount -a [-f] [-r] [-n] [-v] [-t vfstypes] [-O opts]\n"
-	       "       umount [-f] [-r] [-n] [-v] special | node...\n"));
+	       "       umount -a [-f] [-r] [-n] [-v] [-T timeout] [-t vfstypes]=
 [-O opts]\n"
+	       "       umount [-f] [-r] [-n] [-v] [-T timeout] special | node..=
.\n"));
    exit (n);
  }

@@ -659,7 +662,7 @@

  	umask(022);

-	while ((c =3D getopt_long (argc, argv, "adfhlnrit:O:vV",
+	while ((c =3D getopt_long (argc, argv, "adfhlnrit:T:O:vV",
  				 longopts, NULL)) !=3D -1)
  		switch (c) {
  		case 'a':		/* umount everything */
@@ -696,6 +699,9 @@
  		case 't':		/* specify file system type */
  			types =3D optarg;
  			break;
+		case 'T':		/* timeout */
+			timeout =3D atoi(optarg);
+			break;
  		case 'i':
    			external_allowed =3D 0;
  			break;


--=20
Peter =C5strand		ThinLinc Chief Developer
Cendio			http://www.cendio.se
Teknikringen 3
583 30 Link=F6ping        Phone: +46-13-21 46 00
--789237761-1950218555-1143659236=:15464--


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
