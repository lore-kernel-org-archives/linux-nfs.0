From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: default nfs mount options from linux to linux
Date: Thu, 21 Apr 2005 18:42:51 -0700
Message-ID: <1114134171.27207.194.camel@seki.nac.uci.edu>
References: <1114131719.12180.8.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-MSNSmD6L+yvWSyXQU1vB"
Cc: strombrg@dcs.nac.uci.edu, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOnC3-0001xK-E2
	for nfs@lists.sourceforge.net; Thu, 21 Apr 2005 18:42:55 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DOnC2-0008Us-Jd
	for nfs@lists.sourceforge.net; Thu, 21 Apr 2005 18:42:55 -0700
To: Bradford Arrington <brada@cadence.com>
In-Reply-To: <1114131719.12180.8.camel@localhost>
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


--=-MSNSmD6L+yvWSyXQU1vB
Content-Type: multipart/alternative; boundary="=-bF1TVrkWhXt18cAUW2fG"


--=-bF1TVrkWhXt18cAUW2fG
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


If you want to empirically determine a good wsize, for example, you
might try the script below.  I still haven't had a chance to use it, but
I'd like to think it'll work fine.  :)

Also, if you're on a gigabit network, you may be able to improve NFS
performance a lot by turning on jumbo frames.

#!/usr/local/bin/bash
# with these options:
# bg,hard,intr,rsize=3D8192,wsize=3D8192
# we got 50Mbps over NFS to ext3 from esmf04d to esmft2
# I suspect UDP may be faster; we're using tcp here.  Not sure why AIX
# isn't reporting that.

#mount -o vers=3D3,proto=3Dtcp,rsize=3D8192,wsize=3D8192 esmft2:/foo /mnt/f=
oo
for proto in tcp udp
do
   for vers in 3 2
   do
      for size in $(seq 1024 16 65536)
      do
         echo
         echo $vers $proto $size
         cd /
         umount /mnt/foo
         mount -o insecure,vers=3D"$vers",proto=3D"$proto",rsize=3D
$size,wsize=3D$size \
            esmft2:/foo /mnt/foo
         cd /mnt/foo
         rm -f testfile
         # write 10 gigabytes
         echo writing 10 gigabytes: $proto $vers $size
         /bin/time dd if=3D/dev/zero of=3Dtestfile bs=3D1024k count=3D10240=
 2>&1
      done
   done
done


On Thu, 2005-04-21 at 18:01 -0700, Bradford Arrington wrote:

> Does anyone know what or how to find the default mount option are when
> mounting an nfs volume?
> example
> mount linuxnfs:/export /mnt=20
>=20
> How do I find the rsize/wsize and any other options? (that are default)
>=20
> I am lead to believe that the nfs man page information is false for
> r/wsize 1k (no way) (udp default is correct though). If I set the
> r/wsize to 1k performance is very slow. In a "vanilla" default as above
> it has the fastest iozone benchmarks.
>=20
> Thanks,
> -Brad
>=20
>=20
>=20
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now.
> http://ads.osdn.com/?ad_id=3D6595&alloc_id=3D14396&op=3Dclick
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

--=-bF1TVrkWhXt18cAUW2fG
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 TRANSITIONAL//EN">
<HTML>
<HEAD>
  <META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; CHARSET=3DUTF-8">
  <META NAME=3D"GENERATOR" CONTENT=3D"GtkHTML/3.3.2">
</HEAD>
<BODY>
<BR>
If you want to empirically determine a good wsize, for example, you might t=
ry the script below.&nbsp; I still haven't had a chance to use it, but I'd =
like to think it'll work fine.&nbsp; :)<BR>
<BR>
Also, if you're on a gigabit network, you may be able to improve NFS perfor=
mance a lot by turning on jumbo frames.<BR>
<BR>
#!/usr/local/bin/bash<BR>
# with these options:<BR>
# bg,hard,intr,rsize=3D8192,wsize=3D8192<BR>
# we got 50Mbps over NFS to ext3 from esmf04d to esmft2<BR>
# I suspect UDP may be faster; we're using tcp here.&nbsp; Not sure why AIX=
<BR>
# isn't reporting that.<BR>
<BR>
#mount -o vers=3D3,proto=3Dtcp,rsize=3D8192,wsize=3D8192 esmft2:/foo /mnt/f=
oo<BR>
for proto in tcp udp<BR>
do<BR>
&nbsp;&nbsp; for vers in 3 2<BR>
&nbsp;&nbsp; do<BR>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; for size in $(seq 1024 16 65536)<BR>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; do<BR>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; echo<BR>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; echo $vers $proto $size<BR=
>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; cd /<BR>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; umount /mnt/foo<BR>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; mount -o insecure,vers=3D&=
quot;$vers&quot;,proto=3D&quot;$proto&quot;,rsize=3D$size,wsize=3D$size \<B=
R>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; esmft2:/=
foo /mnt/foo<BR>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; cd /mnt/foo<BR>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rm -f testfile<BR>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; # write 10 gigabytes<BR>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; echo writing 10 gigabytes:=
 $proto $vers $size<BR>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /bin/time dd if=3D/dev/zer=
o of=3Dtestfile bs=3D1024k count=3D10240 2&gt;&amp;1<BR>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; done<BR>
&nbsp;&nbsp; done<BR>
done<BR>
<BR>
<BR>
On Thu, 2005-04-21 at 18:01 -0700, Bradford Arrington wrote:
<BLOCKQUOTE TYPE=3DCITE>
<PRE>
<FONT COLOR=3D"#000000">Does anyone know what or how to find the default mo=
unt option are when</FONT>
<FONT COLOR=3D"#000000">mounting an nfs volume?</FONT>
<FONT COLOR=3D"#000000">example</FONT>
<FONT COLOR=3D"#000000">mount linuxnfs:/export /mnt </FONT>

<FONT COLOR=3D"#000000">How do I find the rsize/wsize and any other options=
? (that are default)</FONT>

<FONT COLOR=3D"#000000">I am lead to believe that the nfs man page informat=
ion is false for</FONT>
<FONT COLOR=3D"#000000">r/wsize 1k (no way) (udp default is correct though)=
. If I set the</FONT>
<FONT COLOR=3D"#000000">r/wsize to 1k performance is very slow. In a &quot;=
vanilla&quot; default as above</FONT>
<FONT COLOR=3D"#000000">it has the fastest iozone benchmarks.</FONT>

<FONT COLOR=3D"#000000">Thanks,</FONT>
<FONT COLOR=3D"#000000">-Brad</FONT>



<FONT COLOR=3D"#000000">---------------------------------------------------=
----</FONT>
<FONT COLOR=3D"#000000">SF email is sponsored by - The IT Product Guide</FO=
NT>
<FONT COLOR=3D"#000000">Read honest &amp; candid reviews on hundreds of IT =
Products from real users.</FONT>
<FONT COLOR=3D"#000000">Discover which products truly live up to the hype. =
Start reading now.</FONT>
<FONT COLOR=3D"#000000"><A HREF=3D"http://ads.osdn.com/?ad_id=3D6595&alloc_=
id=3D14396&op=3Dclick">http://ads.osdn.com/?ad_id=3D6595&amp;alloc_id=3D143=
96&amp;op=3Dclick</A></FONT>
<FONT COLOR=3D"#000000">_______________________________________________</FO=
NT>
<FONT COLOR=3D"#000000">NFS maillist  -  <A HREF=3D"mailto:NFS@lists.source=
forge.net">NFS@lists.sourceforge.net</A></FONT>
<FONT COLOR=3D"#000000"><A HREF=3D"https://lists.sourceforge.net/lists/list=
info/nfs">https://lists.sourceforge.net/lists/listinfo/nfs</A></FONT>
</PRE>
</BLOCKQUOTE>
</BODY>
</HTML>

--=-bF1TVrkWhXt18cAUW2fG--

--=-MSNSmD6L+yvWSyXQU1vB
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCaFabo0feVm00f/8RApQdAJ0VEQpt8JKDJl8s0IaWk/R7SCn+qACdH3Ga
yC9ZWJzk0K5eyPWouUeEdKg=
=THpV
-----END PGP SIGNATURE-----

--=-MSNSmD6L+yvWSyXQU1vB--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
