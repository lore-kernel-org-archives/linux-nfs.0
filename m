Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fulla.mrothe.de ([85.17.207.87]:49621 "EHLO fulla.mrothe.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751208Ab2EZMoW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 26 May 2012 08:44:22 -0400
Date: Sat, 26 May 2012 14:37:52 +0200
From: Markus Rothe <markus@mrothe.de>
To: linux-nfs@vger.kernel.org
Subject: nfs-utils 1.2.6: error: #error It appears you have already
 included the Heimdal gssapi.h file
Message-ID: <20120526123752.GB24979@fulla.mrothe.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I am trying to compile nfs-utils 1.2.6 with NFSv4 and gss support, but
am running into the following error:

./configure --prefix=/usr --host=x86_64-pc-linux-gnu --build=x86_64-pc-linux-gnu --mandir=/usr/share/man --infodir=/usr/share/info --datadir=/usr/share --docdir=/usr/share/doc/nfs-utils-1.2.6 --sysconfdir=/etc --localstatedir=/var/lib --disable-dependency-tracking --disable-silent-rules --enable-fast-install --libdir=/usr/lib64 --mandir=/usr/share/man --enable-largefile --enable-libmount-mount --enable-mount --enable-mountconfig --enable-tirpc --with-statduser=nobody --with-statedir=/var/lib/nfs --disable-caps --enable-gss --enable-ipv6 --enable-nfsv4 --enable-nfsv41 --enable-nfsdcld --with-tcp-wrappers
[...]
x86_64-pc-linux-gnu-gcc -DHAVE_CONFIG_H -I. -I../../support/include  -I/usr/include/tirpc -D_GNU_SOURCE -Wall -Wextra -Wstrict-prototypes  -pipe -march=native -O2 -pipe  -I/usr/include/gssglue   -I/usr/include  -march=native -O2 -pipe -c -o gssd-context_lucid.o `test -f 'context_lucid.c' || echo './'`context_lucid.c
In file included from /usr/include/gssapi.h:39:0,
                 from /usr/include/gssapi/gssapi_krb5.h:39,
                 from context_lucid.c:47:
/usr/include/gssglue/gssapi/gssapi.h:42:2: error: #error It appears you have already included the Heimdal gssapi.h file
In file included from context_lucid.c:47:0:
/usr/include/gssapi/gssapi_krb5.h:56:1: error: expected ‘=’, ‘,’, ‘;’, ‘asm’ or ‘__attribute__’ before ‘extern’
/usr/include/gssapi/gssapi_krb5.h:63:41: error: expected ‘=’, ‘,’, ‘;’, ‘asm’ or ‘__attribute__’ before ‘__gss_krb5_mechanism_oid_desc’
/usr/include/gssapi/gssapi_krb5.h:79:1: error: unknown type name ‘GSSAPI_LIB_FUNCTION’
/usr/include/gssapi/gssapi_krb5.h:79:31: error: expected ‘=’, ‘,’, ‘;’, ‘asm’ or ‘__attribute__’ before ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:79:31: error: unknown type name ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:84:1: error: unknown type name ‘GSSAPI_LIB_FUNCTION’
/usr/include/gssapi/gssapi_krb5.h:84:31: error: expected ‘=’, ‘,’, ‘;’, ‘asm’ or ‘__attribute__’ before ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:84:31: error: unknown type name ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:87:1: error: unknown type name ‘GSSAPI_LIB_FUNCTION’
/usr/include/gssapi/gssapi_krb5.h:87:31: error: expected ‘=’, ‘,’, ‘;’, ‘asm’ or ‘__attribute__’ before ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:87:31: error: unknown type name ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:90:1: error: unknown type name ‘GSSAPI_LIB_FUNCTION’
/usr/include/gssapi/gssapi_krb5.h:90:31: error: expected ‘=’, ‘,’, ‘;’, ‘asm’ or ‘__attribute__’ before ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:90:31: error: unknown type name ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:95:1: error: unknown type name ‘GSSAPI_LIB_FUNCTION’
/usr/include/gssapi/gssapi_krb5.h:95:31: error: expected ‘=’, ‘,’, ‘;’, ‘asm’ or ‘__attribute__’ before ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:95:31: error: unknown type name ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:102:1: error: unknown type name ‘GSSAPI_LIB_FUNCTION’
/usr/include/gssapi/gssapi_krb5.h:102:31: error: expected ‘=’, ‘,’, ‘;’, ‘asm’ or ‘__attribute__’ before ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:102:31: error: unknown type name ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:107:1: error: unknown type name ‘GSSAPI_LIB_FUNCTION’
/usr/include/gssapi/gssapi_krb5.h:107:31: error: expected ‘=’, ‘,’, ‘;’, ‘asm’ or ‘__attribute__’ before ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:107:31: error: unknown type name ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:114:1: error: unknown type name ‘GSSAPI_LIB_FUNCTION’
/usr/include/gssapi/gssapi_krb5.h:114:31: error: expected ‘=’, ‘,’, ‘;’, ‘asm’ or ‘__attribute__’ before ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:114:31: error: unknown type name ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:122:1: error: unknown type name ‘GSSAPI_LIB_FUNCTION’
/usr/include/gssapi/gssapi_krb5.h:122:31: error: expected ‘=’, ‘,’, ‘;’, ‘asm’ or ‘__attribute__’ before ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:122:31: error: unknown type name ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:126:1: error: unknown type name ‘GSSAPI_LIB_FUNCTION’
/usr/include/gssapi/gssapi_krb5.h:126:31: error: expected ‘=’, ‘,’, ‘;’, ‘asm’ or ‘__attribute__’ before ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:126:31: error: unknown type name ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:129:1: error: unknown type name ‘GSSAPI_LIB_FUNCTION’
/usr/include/gssapi/gssapi_krb5.h:129:31: error: expected ‘=’, ‘,’, ‘;’, ‘asm’ or ‘__attribute__’ before ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:129:31: error: unknown type name ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:134:1: error: unknown type name ‘GSSAPI_LIB_FUNCTION’
/usr/include/gssapi/gssapi_krb5.h:134:31: error: expected ‘=’, ‘,’, ‘;’, ‘asm’ or ‘__attribute__’ before ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:134:31: error: unknown type name ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:138:1: error: unknown type name ‘GSSAPI_LIB_FUNCTION’
/usr/include/gssapi/gssapi_krb5.h:138:31: error: expected ‘=’, ‘,’, ‘;’, ‘asm’ or ‘__attribute__’ before ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:138:31: error: unknown type name ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:142:1: error: unknown type name ‘GSSAPI_LIB_FUNCTION’
/usr/include/gssapi/gssapi_krb5.h:142:31: error: expected ‘=’, ‘,’, ‘;’, ‘asm’ or ‘__attribute__’ before ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:142:31: error: unknown type name ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:147:1: error: unknown type name ‘GSSAPI_LIB_FUNCTION’
/usr/include/gssapi/gssapi_krb5.h:147:31: error: expected ‘=’, ‘,’, ‘;’, ‘asm’ or ‘__attribute__’ before ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:147:31: error: unknown type name ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:150:1: error: unknown type name ‘GSSAPI_LIB_FUNCTION’
/usr/include/gssapi/gssapi_krb5.h:150:31: error: expected ‘=’, ‘,’, ‘;’, ‘asm’ or ‘__attribute__’ before ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:150:31: error: unknown type name ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:159:1: error: unknown type name ‘GSSAPI_LIB_FUNCTION’
/usr/include/gssapi/gssapi_krb5.h:159:31: error: expected ‘=’, ‘,’, ‘;’, ‘asm’ or ‘__attribute__’ before ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:159:31: error: unknown type name ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:190:2: error: unknown type name ‘OM_uint64’
/usr/include/gssapi/gssapi_krb5.h:191:2: error: unknown type name ‘OM_uint64’
/usr/include/gssapi/gssapi_krb5.h:205:1: error: unknown type name ‘GSSAPI_LIB_FUNCTION’
/usr/include/gssapi/gssapi_krb5.h:205:31: error: expected ‘=’, ‘,’, ‘;’, ‘asm’ or ‘__attribute__’ before ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:205:31: error: unknown type name ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:212:1: error: unknown type name ‘GSSAPI_LIB_FUNCTION’
/usr/include/gssapi/gssapi_krb5.h:212:31: error: expected ‘=’, ‘,’, ‘;’, ‘asm’ or ‘__attribute__’ before ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:212:31: error: unknown type name ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:217:1: error: unknown type name ‘GSSAPI_LIB_FUNCTION’
/usr/include/gssapi/gssapi_krb5.h:217:31: error: expected ‘=’, ‘,’, ‘;’, ‘asm’ or ‘__attribute__’ before ‘GSSAPI_LIB_CALL’
/usr/include/gssapi/gssapi_krb5.h:217:31: error: unknown type name ‘GSSAPI_LIB_CALL’
In file included from /usr/include/stdlib.h:33:0,
                 from gss_util.h:34,
                 from context_lucid.c:49:
/usr/lib64/gcc/x86_64-pc-linux-gnu/4.6.3/include/stddef.h:324:1: error: expected ‘=’, ‘,’, ‘;’, ‘asm’ or ‘__attribute__’ before ‘typedef’
In file included from gss_util.h:34:0,
                 from context_lucid.c:49:
/usr/include/stdlib.h:863:20: error: unknown type name ‘wchar_t’
/usr/include/stdlib.h:867:31: error: unknown type name ‘wchar_t’
/usr/include/stdlib.h:871:25: error: unknown type name ‘wchar_t’
/usr/include/stdlib.h:875:4: error: unknown type name ‘wchar_t’
make[2]: *** [gssd-context_lucid.o] Error 1
make[2]: Leaving directory `/var/tmp/paludis/build/net-fs-nfs-utils-1.2.6/work/nfs-utils-1.2.6/utils/gssd'
make[1]: *** [all-recursive] Error 1
make[1]: Leaving directory `/var/tmp/paludis/build/net-fs-nfs-utils-1.2.6/work/nfs-utils-1.2.6/utils'
make: *** [all-recursive] Error 1


I have the following packages installed:

libgssglue 0.4
heimdal 1.5.2

This is an error with nfs-utils or libgssglue/heimdal?

Regards,

Markus
