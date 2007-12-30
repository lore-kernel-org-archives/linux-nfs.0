From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [NFS] exportfs -r: segfault with sec= option
Date: Sun, 30 Dec 2007 15:16:34 -0500
Message-ID: <200712301516.35053.vapier@gentoo.org>
References: <200712301259.29484.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1360050915=="
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:36850 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754933AbXLaBFq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 30 Dec 2007 20:05:46 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1J9967-00025v-Vf
	for linux-nfs@vger.kernel.org; Mon, 31 Dec 2007 12:05:44 +1100
In-Reply-To: <200712301259.29484.vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--===============1360050915==
Content-Type: multipart/signed; boundary="nextPart5548183.xIAFmlZkz3";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart5548183.xIAFmlZkz3
Content-Type: text/plain;
  charset="iso-8859-6"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Sunday 30 December 2007, Mike Frysinger wrote:
> while testing other things, i was toying with /etc/exports and inserting
> bogus lines.  i found that this simple one makes exportfs segfault:
> /mnt 192.168.0.0(sec=)
> then just run `exportfs -r`
>
> this version of nfs-utils has gss disabled ...

scratch this ... i needed the post-1.1.1 fix for segfaults on amd64 with xlog
-mike

--nextPart5548183.xIAFmlZkz3
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.8 (GNU/Linux)

iQIcBAABAgAGBQJHd/yiAAoJEEFjO5/oN/WBTqYP/A2K1hva4jUEqTK8lfrJmrQ6
Lx1CXCQkNUNht5eZhL17226PnvRC4gxEOB1EBruxmzhVZJrcURDs0n85dBLMAhUr
FMg1ebOkacbwJ9/eS3QnoULzkN5A7jR6Py7XCSUxdECMEUCiqpGMLKaICI8N+BPD
3+/SLu7T/58mwEPfPEyewU3TiXXx5tNrjk/aoU+R3JUAXPIB07QeeIhBThTuuMkv
gmY4jimD+Y9b1TzkqcranklXW78YhKxw44rn9cN6TFtTgOlWrr81/WbB8teR/j0Z
+0r4BNG51nX8cjDg3qutxn9Pcfd/i36QsLqKGoOnAUmMum9aIbenrar8LKmfdIjf
dO2oyiHh0HSqNINhemDuWHKAHpEuFqZ+cnnRlyfzw21jZDdUGUCjx5imtrVm1gyJ
QSSqtBNmI/aHn4VmY3LpkwhBp3vRYueanBer5Uy0v1HvifAaXoeTYK4I3tdby34F
QWzCjLpWbwgsTiG2CS7NxgLNODJjUjl1CFAmvwa8PqPY0/WU6Zfe59oWRWvDwk//
FqsG4RVz+puXMyMZWQWT7A1V/Ds4terNo1ZQjXVxe3tRm8BCx3gfvtZJsanq6GGp
Aj9IkF6HFscgNWNqd3rQzVVgbYxtMzce+pkJC6smSpTdCdL8SfYGHf396dPVa5dZ
bU6XwoCSVjrWsc8ShWSi
=wLap
-----END PGP SIGNATURE-----

--nextPart5548183.xIAFmlZkz3--


--===============1360050915==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--===============1360050915==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--===============1360050915==--


