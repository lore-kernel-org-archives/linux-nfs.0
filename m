Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6137 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750997Ab3KDTbD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Nov 2013 14:31:03 -0500
Date: Mon, 4 Nov 2013 14:30:56 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Steve Dickson <SteveD@redhat.com>, Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "dpquigl@davequigley.com" <dpquigl@davequigley.com>
Subject: Re: Labeled NFS: Is the value of FATTR4_WORD2_SECURITY_LABEL
 correct?
Message-ID: <20131104143056.36474416@tlielax.poochiereds.net>
In-Reply-To: <58879923-7AE9-4E5B-A29E-4EA26E8330DD@netapp.com>
References: <1383389838-1858-1-git-send-email-jlayton@redhat.com>
	<C85EF88C-B4F8-484C-A00D-5A86ACB61C10@netapp.com>
	<5277BAFB.9070109@RedHat.com>
	<48054582-1F6A-4A27-AE62-C9B0AE8F9619@netapp.com>
	<5277DFBB.1010901@RedHat.com>
	<58879923-7AE9-4E5B-A29E-4EA26E8330DD@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 4 Nov 2013 19:20:09 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> AFAICS from draft-ietf-nfsv4-minorversion2-20.txt, the ‘sec_label’ attribute has Id == 80.
> 
> Shouldn’t that mean that FATTR4_WORD2_SECURITY_LABEL should take the value (1 << (80-64))?
> 
> i.e.
> 
> #define FATTR4_WORD2_SECURITY_LABEL (1UL << 16)
> 
> instead of the current value of (1UL << 17)…
> 
> Trond
> 

Yeah, that does look wrong. Well spotted!

Just to sanity check, the mdsthreshold bit is listed as bit 68 in
RFC5661:

    #define FATTR4_WORD2_MDSTHRESHOLD       (1UL << 4)

...so if we assume that that's correct, then
FATTR4_WORD2_SECURITY_LABEL is really set to the value for
change_sec_label...

-- 
Jeff Layton <jlayton@redhat.com>
