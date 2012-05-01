Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53258 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753339Ab2EARBt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 May 2012 13:01:49 -0400
Date: Tue, 1 May 2012 13:01:47 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
Cc: "<SteveD@redhat.com>" <SteveD@redhat.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: add IPv6 addr escaping to fs_location hosts
Message-ID: <20120501170147.GA31034@fieldses.org>
References: <1335279577-46822-1-git-send-email-dros@netapp.com>
 <20120427112529.GA14973@fieldses.org>
 <975131E5-DBB4-4C78-904E-EA577B748DD4@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <975131E5-DBB4-4C78-904E-EA577B748DD4@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 01, 2012 at 04:09:55PM +0000, Adamson, Dros wrote:
> 
> On Apr 27, 2012, at 7:25 AM, J. Bruce Fields wrote:
> 
> > On Tue, Apr 24, 2012 at 10:59:37AM -0400, Weston Andros Adamson wrote:
> >> The fs_location->hosts list is split on colons, but this doesn't work when
> >> IPv6 addresses are used (they contain colons).
> >> This patch adds the function nfsd4_encode_components_esc() to
> >> allow the caller to specify escape characters when splitting on 'sep'.
> >> In order to fix referrals, this patch must be used with the mountd patch
> >> that similarly fixes IPv6 [] escaping.
> > 
> > Thanks, looks fine, applying with one trivial change:
> > 
> >> -		for (; *end && (*end != sep); end++)
> >> -			; /* Point to end of component */
> >> +		bool found_esc = false;
> >> +
> >> +		/* try to parse as esc_start, ..., esc_end, sep */
> >> +		if (*str == esc_enter) {
> >> +			for (; *end && (*end != esc_exit); end++);
> > 
> > I kinda like keeping the semicolon on its own line here.  Tastes may
> > differ.
> 
> Yeah, as Jim pointed out checkpatch will complain if it's not -- you already found my updated diff.
> 
> > (Also: how did you test this?)
> 
> I testsed this patch along with the corresponding mountd patch using two servers:
> 
> [fc00::10] - exporting /export, /export/refer @ [fc00:41]:/export
> [fc00::41] - exporting /export
> 
> On a client machine (with recently posted client-side fix), I mount [fc00::10]:/export on /mnt, then cd to /mnt/refer.
> 
> Without these patches, wireshark sees a list of referral locations: "[fc00", "", "10]", which is obviously wrong.
> With these patches the cd to /mnt/refer works as [fc00::41]:/export is mounted at /mnt/refer.

Sounds good.  Thanks!

--b.
