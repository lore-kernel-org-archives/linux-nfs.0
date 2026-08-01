Received: from mout.gmx.net (mout.gmx.net [212.227.15.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0E6B821A42D
	for <linux-nfs@vger.kernel.org>; Sat,  1 Aug 2026 15:53:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.15.19
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785599631; cv=none; b=GL/8K2tYQ+yvKvV+Bbsg2Oo3bMrvkjWginzLtAjYbenViW5LZSLtcRnJ2rvs0eD7fnp1+G6d6cBkIWhhD3lKp5pzSjO4En9+Sg+jGOh6JTuXHgX5SPEows/N3KMgiSvT9CcAp1RE1bKGzJkk5v13le89qZUGSEYQHt17eU1wNSE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785599631; c=relaxed/simple;
	bh=V0WltRCHxcdNIrvcxHCx9tVw8SWmwWJIo2n71hFwChw=;
	h=Date:From:To:Subject:Message-ID:MIME-Version:Content-Type; b=YZoRGooflg8HVcAtsXyGlweVCP/FnLhKFqReoWnzHjDJfAP5HNL2kCjhMD46LuvCN4FK7i2Rp2nUvjPTKdkeWhV/c4XdPCk/JjBg35y8uAiYztgDw4kU0feIBmF3N7ObKRZy3Fk3RfS7ACQg/wMYMze9LOeEbrYLgqrFj093AGA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.de; spf=pass smtp.mailfrom=gmx.de; dkim=pass (2048-bit key) header.d=gmx.de header.i=polynomial-c@gmx.de header.b=cbkZCd1+; arc=none smtp.client-ip=212.227.15.19
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmx.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmx.de header.i=polynomial-c@gmx.de header.b="cbkZCd1+"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmx.de;
	s=s31663417; t=1785599627; x=1786204427; i=polynomial-c@gmx.de;
	bh=1cSRzluuYZbk5vKE/B4K+SMobmWyZviqOg/jVfJqH/I=;
	h=X-UI-Sender-Class:Date:From:To:Subject:Message-ID:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:cc:
	 content-transfer-encoding:content-type:date:from:message-id:
	 mime-version:reply-to:subject:to;
	b=cbkZCd1+lktwobVCJ8XCM5v4CkXqdWgtTwweOsJhJ2pqTepq9IaWj/Ki+yakTK9s
	 rsVQMejCCEWH9mqTA74VFQCc3aGj7GQJDOikgstCNUKqwSntk2fIQYNlOKl95aVke
	 cB+t7BkVUjf16dokcx296vuzhH7JdW0ZtqySYVw0+8c8JwN0rM+9X6VuH5Tdi9mUx
	 +VDm+TwJtC4DWy6e37jNFUQxmdrB6In7Zh3eZ8u/VDFeUE19b7TOldk9Jx+iAj93I
	 OGYQnze5+SvtAP8TAi2Sls1cTGWzr1AZihDiPsnSLDPcEnNZE4la28c8nLE3Py8EW
	 bK04b9sU8VsiI8p+bw==
X-UI-Sender-Class: 724b4f7f-cbec-4199-ad4e-598c01a50d3a
Received: from client.hidden.invalid by mail.gmx.net (mrgmx005
 [212.227.17.190]) with ESMTPSA (Nemesis) id 1MpUZ4-1xHqkx00BI-00eoSe for
 <linux-nfs@vger.kernel.org>; Sat, 01 Aug 2026 17:53:47 +0200
Date: Sat, 1 Aug 2026 17:53:46 +0200
From: Lars Wendler <polynomial-c@gmx.de>
To: linux-nfs@vger.kernel.org
Subject: 2.9.2 release: --disable-nfsdctl breaks build
Message-ID: <20260801175346.4d948b87@chagall.paradoxon.rec>
Organization: privat
X-Mailer: Claws Mail 4.4.0 (GTK 3.24.52; x86_64-pc-linux-gnu)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Provags-ID: V03:K1:7+tOWsAVAmESyEovs6yCo1Ys80pEFLkoypP2w3yfxfcwaZ1WZqm
 q2/ORMgFvLVPwU7fgfj4Px1DsqsBXD8K0DAEZdd0UkoRQSO2ksLFKlW6BmiRFMtrDLyLwP3
 S2hc13Z4J3YrybsyNbx2D+lQWTynp+cCE7uqk4g97H/SvwILTxZFMzfAW/DJxbrjS8EnVzD
 6tFjeQsIMfrc/KoVahUsg==
X-Spam-Flag: NO
UI-OutboundReport: notjunk:1;M01:P0:GmfRDEjN3Uc=;WejYSJGKQhNOmieZVHbuF469air
 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

Hi,

trying to test 2.9.2 release I stumbled upon a compile error using
this set of configure switches:

--disable-static --with-statedir=/var/lib/nfs --enable-tirpc
--with-tirpcinclude=/usr/include/tirpc/
--with-pluginpath=/usr/lib64/libnfsidmap --with-rpcgen
--with-systemd=/usr/lib/systemd/system --without-gssglue --enable-caps
--enable-ipv6 --disable-junction --disable-gss --disable-svcgss
--disable-ldap --enable-libmount-mount --disable-nfsdctl --enable-nfsv4
--enable-blkmapd --enable-nfsdcld --enable-nfsdcltrack
--enable-nfsv4server --enable-uuid --without-krb5 --without-tcp-wrappers

Here's the error:

libtool: link: x86_64-pc-linux-gnu-gcc -Wall -Wextra
-Werror=strict-prototypes - fno-strict-aliasing -march=native
-mtune=native -O2 -pipe -Wl,-O1 -Wl,--hash-style=gnu -Wl,--sort-common
-Wl,-z -Wl,relro -Wl,-z -Wl,now -Wl,-z -Wl,pack-relative-relocs -o
exportfs exportfs-exportfs.o  -Wl,--as-needed
../../support/export/libexport.a ../../support/nfs/.libs/libnfs.a
-luuid ../../support/misc/libmisc.a
../../support/reexport/libreexport.a -lpthread -lnl-genl-3 -lnl-3
-lresolv
/usr/x86_64-pc-linux-gnu/binutils-bin/2.47/ld: exportfs-exportfs.o: in
function `unexportfs_parsed':
exportfs.c:(.text+0xfbe): undefined reference to `nfsd_nl_cmd_str'
collect2: error: ld returned 1 exit status
make[2]: *** [Makefile:535: exportfs] Error 1
make[2]: Leaving directory
'/var/tmp/portage/net-fs/nfs-utils-2.9.2/work/nfs-utils-2.9.2/utils/exportfs'

Switching --disable-nfsdctl to --enable-nfsdctl in the above set of
configure flags makes the build succeed.

Kind regards
Lars
