From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Thu, 31 Jul 2008 21:31:29 -0400
Message-ID: <76bd70e30807311831p771d0f1eia3e303bd84919422@mail.gmail.com>
References: <1209670979.25560.587.camel@pmac.infradead.org>
	 <20080501204820.GA5951@infradead.org>
	 <1209681898.25560.613.camel@pmac.infradead.org>
	 <18458.28833.539314.455215@notabene.brown>
	 <1217541264.1126.15.camel@shinybook.infradead.org>
	 <18578.21997.529551.676627@notabene.brown>
	 <1217551230.3719.15.camel@shinybook.infradead.org>
	 <76bd70e30807311753m2785c6d3kd82edd1fe8b5f8b7@mail.gmail.com>
	 <1217552437.3719.30.camel@shinybook.infradead.org>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Neil Brown" <neilb@suse.de>,
	"Christoph Hellwig" <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: "David Woodhouse" <dwmw2@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:46359 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753191AbYHABba (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Jul 2008 21:31:30 -0400
Received: by fg-out-1718.google.com with SMTP id 19so421910fgg.17
        for <linux-nfs@vger.kernel.org>; Thu, 31 Jul 2008 18:31:29 -0700 (PDT)
In-Reply-To: <1217552437.3719.30.camel-Fexsq3y4057IgHVZqg5X0TlWvGAXklZc@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 31, 2008 at 9:00 PM, David Woodhouse <dwmw2@infradead.org> wrote:
> On Thu, 2008-07-31 at 20:53 -0400, Chuck Lever wrote:
>> For now it is sufficient, IMO.  NFSv4 doesn't implement a readdirplus
>> operation, and the performance benefits of NFSv3 readdirplus are
>> equivocal -- there isn't a strong desire to replicate the complexity
>> of NFSv3 readdirplus in NFSv4.  I'm not even sure you can do it even
>> with a single compound RPC, so even in the long run NFSv4 may not ever
>> have the locking issues that NFSv3 does here.
>
> AFAICT NFSv4 does have the same recursion issues already. The call trace
> goes fs->readdir() ... nfsd4_encode_dirent() ...
> nfsd4_encode_dirent_fattr() ... lookup_one_len() ... fs->lookup().
>
> Or am I mistaken?

It looks like it needs a directory entry's dentry for a couple of reasons:

1.  To determine whether a directory entry is a mount point

2.  If the client has asked for file handles (via a bitmask) for the
directory entries

So, yep, you're right.  NFSv4 will hit this too.

As I recall, the Linux NFSv4 client doesn't use
FATTR4_WORD0_FILEHANDLE during NFSv4 READDIR for the reasons I stated
earlier; and it only uses FATTR4_WORD0_FSID during GETATTR.  Other
clients might use these during a READDIR however.

-- 
 "Alright guard, begin the unnecessarily slow-moving dipping mechanism."
--Dr. Evil
