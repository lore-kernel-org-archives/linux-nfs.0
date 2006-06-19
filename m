From: Michael Halcrow <mhalcrow@us.ibm.com>
Subject: Possible bugs in nfs-utils
Date: Mon, 19 Jun 2006 15:30:25 -0500
Message-ID: <20060619203025.GA7102@us.ibm.com>
Reply-To: Michael Halcrow <mhalcrow@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1102585691=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FsQOK-0003nc-Rh
	for nfs@lists.sourceforge.net; Mon, 19 Jun 2006 13:30:36 -0700
Received: from e4.ny.us.ibm.com ([32.97.182.144])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FsQOK-00067B-Cy
	for nfs@lists.sourceforge.net; Mon, 19 Jun 2006 13:30:37 -0700
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	k5JKUTUl002639
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <nfs@lists.sourceforge.net>; Mon, 19 Jun 2006 16:30:29 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id
	k5JKUTx1262666
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <nfs@lists.sourceforge.net>; Mon, 19 Jun 2006 16:30:29 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	k5JKUTYP007801
	for <nfs@lists.sourceforge.net>; Mon, 19 Jun 2006 16:30:29 -0400
Received: from localhost.localdomain (dyn95340152.austin.ibm.com [9.53.40.152])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	k5JKUT3U007792
	for <nfs@lists.sourceforge.net>; Mon, 19 Jun 2006 16:30:29 -0400
Received: from mhalcrow by localhost.localdomain with local (Exim 4.50)
	id 1FsQO9-0001tX-P1
	for nfs@lists.sourceforge.net; Mon, 19 Jun 2006 15:30:25 -0500
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


--===============1102585691==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="5mCyUwZo2JvN/JJP"
Content-Disposition: inline


--5mCyUwZo2JvN/JJP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

I ran nfs-utils through the Coverity source code scanner, and the
following items were flagged that I thought might merit a second
glance (source from util-linux-2.13-pre7.tar.bz2). Those with a more
intimate knowledge of the code base can probably help out in
determining whether some of these really are problematic:

---
support/nfs/svc_socket.c::svc_socket():

If ret == 0 and rpcp == NULL, then servp is checked for non-NULL
status before it is initialized.
---

---
utils/rquotad/rquota_server.c::getquotainfo():

qfpathname may be leaked.
---

---
utils/statd/notlist.c::nlist_new():

new may be leaked here:
        if (!(NL_MY_NAME(new) = xstrdup(my_name))
                        || !(NL_MON_NAME(new) = xstrdup(mon_name)))
                return NULL;
---

---
tools/rpcgen/rpc_parse.c::get_definition():

defp may be leaked on tok.kind == TOK_EOF.
---

---
utils/idmapd/cfg.c::conf_get_tag_list():

node may be leaked here:
        if (!node->field)
          goto cleanup;
...
 cleanup:
  if (list)
    conf_free_list (list);
  return 0;

Same issue in conf_get_list().
---

---
support/misc/mountpoint.c::is_mountpoint():

No check for NULL result from malloc here:
        dotdot = malloc(strlen(path)+4);
        strcat(strcpy(dotdot, path), "/..");

dotdot not freed prior to return.
---

---
utils/idmapd/cfg.c::conf_remove():

Dereference NULL pointer:
  node = conf_trans_node (transaction, CONF_REMOVE);
  if (!node)
    goto fail;
...
 fail:
  if (node->section)
    free (node->section);
---

---
tools/rpcgen/rpc_parse.c::def_const():

Dead code here:
    flag=0;
    if(peekscan(TOK_CASE,&tok))
      {

        do
          {
            scan2(TOK_IDENT, TOK_CHARCONST, &tok);
            cases->contflag=1;  /* continued case statement */
            *tailp = cases;
            tailp = &cases->next;
            cases = ALLOC(case_list);
            cases->case_name = tok.str;
            scan(TOK_COLON, &tok);

          }while(peekscan(TOK_CASE,&tok));
      }
    else
      if(flag)
        {

          *tailp = cases;
          tailp = &cases->next;
          cases = ALLOC(case_list);
        };

It looks like flag will always be 0 at the if(flag) check.
---

---
utils/idmapd/idmapd.c::mydaemon():

tempfd not checked (not likely to be a problem for /dev/null, but just
in case):
                tempfd = open("/dev/null", O_RDWR);
                dup2(tempfd, 0);
---

---
support/nfs/cacheio.c::cache_flush():

Return value not checked:
stat(_PATH_ETAB, &stb);
---

---
tools/rpcgen/rpc_scan.c::docppline():

Return without freeing storage.
---

Thanks,
Mike

--5mCyUwZo2JvN/JJP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iQEVAwUBRJcJYdtAhTFtyodpAQKERggAk8L0Gek9+Yk/D84NiiA/9SsHX6q3sJhF
XPrZpMPGZQNFo4vVnA4FjCMP+kqnkYap2rVpk3UM0KQDXkY9muHUFBfccUCLUkCA
RWY3HLW1W5l6AStzJJmxwHetcZeNdk/w4IXv7GLluRMpP0SkOy6s4O0SkDR78wNJ
CkUAY1RBsgqgTSpQrLsuladvsGrKv2l4fp4rh6Jx/SWhTEJDbC7ZMwa9H79d5XT/
H9b88Z2On1zm94XBR55Zd4x4pfur/rXDd9P8r/Cpe0ou19Qwlph365on0QL5VEfn
FcbEZ/6F0im28Yqkg2LWGhPVO12OId1NCzws4SosK6Z3Z7mX9JPRTQ==
=qzTz
-----END PGP SIGNATURE-----

--5mCyUwZo2JvN/JJP--


--===============1102585691==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============1102585691==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1102585691==--
