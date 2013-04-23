Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([69.128.83.226]:2957 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756508Ab3DWStl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Apr 2013 14:49:41 -0400
Date: Tue, 23 Apr 2013 14:43:01 -0400 (EDT)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: Simo Sorce <simo@redhat.com>
Cc: samba-technical@lists.samba.org,
        fedfs-utils Developers <fedfs-utils-devel@oss.oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>
Message-ID: <189824864.86.1366742581325.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <1366742262.7239.131.camel@willson.li.ssimo.org>
Subject: Re: Interoperable junctions on Linux
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


----- "Simo Sorce" <simo@redhat.com> wrote:

> 
> Well I have some knowledge in this field, and I do not find it very
> fiddly, but I may be biased as I have been working for the past 7
> years
> to make LDAP+Kerberos simple to manage within the FreeIPA project.
> Your requirement to set an objectclass on the base suffix is something
> I
> find particularly unappealing, and no other tool that I know of
> requires
> this (because it is unnecessary).

Yes.  Thank you.

> > 
> 
> I think you should allow the broadest possibilities of course, which
> is
> why I am picking on things like allowing SSAL/GSSAPI explicitly in
> the
> RFC language. Whether people will integrate into existing LDAP server
> or
> not remains to be seen, if we can avoid the need to add an objectlass
> on
> the root suffix I see that we can easily add this a standard feature
> for
> FreeIPA as well (we already provide automount data for example) and
> provide management tools in our framework around it.

I noted this point on a FedFS concall 2 years ago.  I dont understand why
not -permit- easy integration with existing LDAP infrastructure.


-- 
Matt Benjamin
The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel.  734-761-4689 
fax.  734-769-8938 
cel.  734-216-5309 
