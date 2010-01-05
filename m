From: Steve Dickson <SteveD@redhat.com>
Subject: Re: rpcbind doesn't build on Fedora 12 ?
Date: Tue, 05 Jan 2010 13:44:13 -0500
Message-ID: <4B43887D.2000006@RedHat.com>
References: <268D6516-A19A-4CC7-BF03-6FBFA7C79D0B@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64852 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755136Ab0AESoR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Jan 2010 13:44:17 -0500
In-Reply-To: <268D6516-A19A-4CC7-BF03-6FBFA7C79D0B@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/05/2010 12:12 PM, Chuck Lever wrote:
> security.c:24:27: error: rpcsvc/rquota.h: No such file or directory
> security.c: In function =91check_callit=92:
> security.c:286: error: =91RQUOTAPROG=92 undeclared (first use in this=
 function)
> security.c:286: error: (Each undeclared identifier is reported only o=
nce
> security.c:286: error: for each function it appears in.)
>=20
> I have libtirpc-devel installed, but a "find" on /usr/include turns u=
p
> no file named rquota.h.  Am I missing some other package?
>=20
Yeah... 'yum install quota-devel' is your friend...=20

steved.
=20
