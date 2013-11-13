Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:25936 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757947Ab3KMEP2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Nov 2013 23:15:28 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NeilBrown <neilb@suse.de>, Charles Edward Lever <chuck.lever@oracle.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_secure_mounts bool
Date: Wed, 13 Nov 2013 04:15:26 +0000
Message-ID: <1384316126.15992.33.camel@leira.trondhjem.org>
References: <1384037221-7224-1-git-send-email-steved@redhat.com>
	 <E061C7A8-DC27-49BA-93C2-DC2E9C19EA7B@netapp.com>
	 <52811CBB.3070204@RedHat.com>
	 <E520DD5F-7E5A-4B6C-9FF6-6B74DA36FD1E@oracle.com>
	 <5281290B.6000201@RedHat.com>
	 <E0FBCF46-C70F-41E5-BA67-48406253CD7E@oracle.com>
	 <20131112161135.25a487da@notabene.brown>
	 <F58540AB-00BE-4AC5-B823-7260F30F8D58@netapp.com>
	 <20131112161634.GC15060@fieldses.org>
	 <20131113112346.3f5f3bd0@notabene.brown>
	 <20131113034636.GA32628@fieldses.org>
In-Reply-To: <20131113034636.GA32628@fieldses.org>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-11-12 at 22:46 -0500, J. Bruce Fields wrote:

+AD4- OK, but it still seems dumb to even attempt the reverse lookup: the
+AD4- lookup probably isn't secure, and the mount commandline should have a
+AD4- name that we can match to a krb5 principal without needing any other
+AD4- lookups.
+AD4- 
+AD4- So I'd think reasonable behavior in this case would be to just try the
+AD4- IP address on the chance there's actually an nfs/x.y.z.w+AEA-REALM
+AD4- principal.  (Or just fail outright if kerberos doesn't allow principals
+AD4- that look like that.)

Looking through the krb5.conf manpage etc it looks as if a lot of this
functionality should be covered by the krb protocol itself without us
needing to do explicit reverse lookups in rpc.gssd. I'm thinking of the
'canonicalize' and 'rdns' options, for instance. Am I wrong?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
