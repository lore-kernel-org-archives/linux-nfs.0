Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50696 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757618Ab3EGUok (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 May 2013 16:44:40 -0400
Date: Tue, 7 May 2013 16:44:33 -0400
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 03/17] NFSDv4.2: Added NFS v4.2 support to the NFS server
Message-ID: <20130507204433.GC32743@fieldses.org>
References: <1367240239-19326-1-git-send-email-SteveD@redhat.com>
 <1367240239-19326-4-git-send-email-SteveD@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1367240239-19326-4-git-send-email-SteveD@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 29, 2013 at 08:57:05AM -0400, Steve Dickson wrote:
> From: Steve Dickson <steved@redhat.com>
> 
> This enable NFSv4.2 support for the server. To enable this
> code do the following:
>   echo "+4.2" >/proc/fs/nfsd/versions
> 
> after the nfsd kernel module is loaded.

We also need one more change to get working 4.2.

--b.

commit e4819461ed826bfafd899eb8719edb15f0fb68f4
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue May 7 11:57:52 2013 -0400

    nfsd4: store correct client minorversion for >=4.2
    
    This code assumes that any client using exchange_id is using NFSv4.1,
    but with the introduction of 4.2 that's no longer true.
    
    This main effect of this is that client callbacks will use the same
    minorversion as that used on the exchange_id.
    
    Note that clients are forbidden from mixing 4.1 and 4.2 compounds.  (See
    rfc 5661, section 2.7, #13: "A client MUST NOT attempt to use a stateid,
    filehandle, or similar returned object from the COMPOUND procedure with
    minor version X for another COMPOUND procedure with minor version Y,
    where X != Y.")  However, we do not currently attempt to enforce this
    except in the case of mixing zero minor version with non-zero minor
    versions.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 316ec84..91ead0e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1709,7 +1709,7 @@ out_new:
 		status = nfserr_jukebox;
 		goto out;
 	}
-	new->cl_minorversion = 1;
+	new->cl_minorversion = cstate->minorversion;
 
 	gen_clid(new, nn);
 	add_to_unconfirmed(new);
