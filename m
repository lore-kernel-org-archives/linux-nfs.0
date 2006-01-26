From: Emil Obermayr <nobs@tigress.com>
Subject: dqoff not found
Date: Thu, 26 Jan 2006 17:25:14 +0100
Message-ID: <20060126172514.A26708@tigress.com>
Reply-To: Emil Obermayr <nobs@tigress.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F29w3-0000R4-9J
	for nfs@lists.sourceforge.net; Thu, 26 Jan 2006 08:25:23 -0800
Received: from hydrogen.yatho.de ([217.24.218.165])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1F29w1-0003x3-I4
	for nfs@lists.sourceforge.net; Thu, 26 Jan 2006 08:25:23 -0800
Received: (from nobs@localhost)
	by hydrogen.yatho.de (8.11.6/8.11.6) id k0QGPEq32387
	for nfs@lists.sourceforge.net; Thu, 26 Jan 2006 17:25:14 +0100
To: nfs@lists.sourceforge.net
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

Hi,

I just tried to build nfs-utils 1.08rc2 and it failed=20
because dqoff and dq_dqb are missing

system here is a suse 9.3 with "vanilla kernel" 2.6.15

with --disable-rquotad it compiles nicely

here is the output:

Making all in rquotad
make[2]: Entering directory `/usr/local/src/nfs-utils-1.0.8-rc2/utils/rqu=
otad'
if gcc -DHAVE_CONFIG_H -I. -I. -I../../support/include  -I../../support/i=
nclude -D_FILE_OFFSET_BITS=3D64 -D_GNU_SOURCE -I../../support/export -D_G=
NU_SOURCE -Wall  -pipe -g -O2 -MT rquotad-rquota_server.o -MD -MP -MF ".d=
eps/rquotad-rquota_server.Tpo" -c -o rquotad-rquota_server.o `test -f 'rq=
uota_server.c' || echo './'`rquota_server.c; \
then mv -f ".deps/rquotad-rquota_server.Tpo" ".deps/rquotad-rquota_server=
.Po"; else rm -f ".deps/rquotad-rquota_server.Tpo"; exit 1; fi
rquota_server.c: In Funktion =C2=BBgetquotainfo=C2=AB:
rquota_server.c:78: error: storage size of `dq_dqb' isn't known
rquota_server.c:146: Warnung: implicit declaration of function `dqoff'
rquota_server.c:147: error: invalid application of `sizeof' to an incompl=
ete type
rquota_server.c:153: error: invalid application of `sizeof' to an incompl=
ete type
rquota_server.c:155: error: invalid application of `sizeof' to an incompl=
ete type
rquota_server.c:155: error: duplicate case value
rquota_server.c:148: error: previously used here
rquota_server.c:78: Warnung: unused variable `dq_dqb'

If something special is needed for rquotad it should be tested by configu=
re, IMHO.

Bye!

Emil 'nobs' Obermayr



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
