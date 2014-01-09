Return-Path: linux-nfs-owner@vger.kernel.org
Received: from gw1.transmode.se ([195.58.98.146]:50764 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754901AbaAIQ0L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Jan 2014 11:26:11 -0500
In-Reply-To: <52CEC911.4080506@RedHat.com>
References: <OFDD407A92.688D29A1-ONC1257C43.00634FC8-C1257C43.00645775@transmode.se> <20131216185419.GB31816@fieldses.org> <20131216200301.GD31816@fieldses.org> <OF149AE409.624B2B0A-ONC1257C43.006F77D7-C1257C43.006FCED2@transmode.se> <20131216202345.GF31816@fieldses.org> <OF942071D7.5EC379B1-ONC1257C43.007AB858-C1257C43.007B0CFB@transmode.se> <20131217034331.GB3490@fieldses.org> <52CC6B49.2070801@RedHat.com> <OF3BA89263.49226136-ONC1257C59.007AE7CD-C1257C59.007AFB8A@transmode.se> <52CEC911.4080506@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
MIME-Version: 1.0
Subject: Re: [PATCH] nfsd: fix minorversion-choosing interface
From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Message-ID: <OF888A4A56.F15FF112-ONC1257C5B.0059FFA6-C1257C5B.005A4864@transmode.se>
Date: Thu, 9 Jan 2014 17:26:07 +0100
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson <SteveD@redhat.com> wrote on 2014/01/09 17:06:41:
> 
> 
> On 07/01/14 17:23, Joakim Tjernlund wrote:
> > Steve Dickson <SteveD@redhat.com> wrote on 2014/01/07 22:02:01:
> >>
> >>
> >> On 16/12/13 22:43, J. Bruce Fields wrote:
> >>> From: "J. Bruce Fields" <bfields@redhat.com>
> >>>
> >>> By unconditionally adding +/-4.2 to the version string written to 
the
> >>> kernel we make nfs-utils incompatible with pre-4.2-supporting 
kernels.
> >>>
> >>> Ditto for 4.1.  This problem was introduced by
> >>> 12a590f8d556c00a9502eeebaa763d906222d521 "rpc.nfsd: Allow v4.2 
server
> >>> support with the -V option", which also change nfsd to 
unconditionally
> >>> pass +/-4.2.
> >>>
> >>> Instead, just don't mention 4.1 or 4.2 unless the commandline has
> >>> specifically requested that one or the other be turned on or off.
> >>>
> >>> Tested-by: Joakim Tjernlund <joakim.tjernlund@transmode.se>
> >>> Reported-by: Joakim Tjernlund <joakim.tjernlund@transmode.se>
> >>> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> >> Committed...
> >>
> >> steved
> > 
> > Thanks, do plan on making a release soon?
> Sorry for the delayed response... 
> 
> Its in my git tree and in Fedora 20 nfs-utils....
> 
> Is this what you were looking for? 

No, I am wondering when nfs-utils 1.2.10 will be released, but I see now 
that
the tree is tagged with 1-2-10-rc2 so I guess it will be soon.

 Jocke
