Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:21331 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752598Ab3KDRWr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Nov 2013 12:22:47 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: [PATCH 4/4] NFSD: Implement SEEK
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20131104170510.GB31499@infradead.org>
Date: Mon, 4 Nov 2013 09:22:11 -0800
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org
Message-Id: <89CF7DF4-50B3-4EF4-B756-FDAFAC44F298@oracle.com>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com> <1382972247-1108-5-git-send-email-bjschuma@netapp.com> <20131029073558.GA10889@infradead.org> <526FB180.1060003@netapp.com> <20131029130721.GA32094@infradead.org> <20131029133006.GB29606@fieldses.org> <20131102134837.GA18961@infradead.org> <20131102143729.GA26983@fieldses.org> <20131102144107.GA28743@infradead.org> <20131104164658.GA4427@fieldses.org> <20131104170510.GB31499@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 4, 2013, at 9:05 AM, Christoph Hellwig <hch@infradead.org> wrote:

> On Mon, Nov 04, 2013 at 11:46:58AM -0500, J. Bruce Fields wrote:
>> Imagine it was me, if it helps.
>> 
>> The important thing is that we understand what should be fixed.
> 
> The important part is how someone got the idea for the pattern writing
> and the weird ADBs from

The original proposal is

  http://tools.ietf.org/html/draft-eisler-nfsv4-enterprise-apps-01

and has been somewhat modified in its expression in NFSv4.2.

> and why they believe they should overload a
> single command for all of them.

I believe that file initialization is closer in semantics to COPY_OFFLOAD than it is to WRITE, and I find it awkward to use the WRITE_PLUS operation for initialization.  But I could never make a strong technical argument why they should not be joined, other than "Clutter!".

> And apparently reqular data writes as
> well, even if I haven't found that part of the spec yet.

  http://www.ietf.org/id/draft-ietf-nfsv4-minorversion2-20.txt

is the latest version I can find.

The usual process is to explain what needs to be fixed (ie, make a problem statement) as Bruce said.  That is often accompanied by an alternate design proposal that addresses your issues.

It is appropriate to address your comments to the group, and not to a single person.  As in most online communities, ad hominem and confrontation are not appreciated.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



