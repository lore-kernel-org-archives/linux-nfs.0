Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:41341 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755485Ab3KMAay convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Nov 2013 19:30:54 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: NeilBrown <neilb@suse.de>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Charles Edward Lever <chuck.lever@oracle.com>,
        Steve Dickson <SteveD@redhat.com>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_secure_mounts bool
Date: Wed, 13 Nov 2013 00:30:53 +0000
Message-ID: <1384302651.15992.3.camel@leira.trondhjem.org>
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
In-Reply-To: <20131113112346.3f5f3bd0@notabene.brown>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-11-13 at 11:23 +-1100, NeilBrown wrote:
+AD4- But back to my problem:  Following Trond's suggestion I've come up with the
+AD4- following patch.  Does it look right?
+AD4- 
+AD4- The +ACI-fd +AD0- -1+ACI- is just to stop us trying to close a non-open fd in an error
+AD4- path.
+AD4- 
+AD4- The change from testing -+AD4-servicename to -+AD4-prog stops us from repeating the
+AD4- failed DNS lookup on every request, not that the failure isn't fatal.
+AD4- 
+AD4- The last stanza makes sure we always reply to an upcall, with EINVAL if
+AD4- nothing else seems appropriate.

Wouldn't EACCES be more appropriate as a default?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
