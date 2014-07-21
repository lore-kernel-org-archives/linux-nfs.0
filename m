Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35985 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932420AbaGUPzp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Jul 2014 11:55:45 -0400
Date: Mon, 21 Jul 2014 11:55:43 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: fuzz tested user mode linux crashed in NFS code path
Message-ID: <20140721155543.GD8438@fieldses.org>
References: <53C10EAA.2000802@gmx.de>
 <53C12A93.3040803@gmail.com>
 <20140716185724.GC2397@fieldses.org>
 <20140717202721.GG30442@fieldses.org>
 <53C949DC.5060008@gmx.de>
 <53C9505D.80601@gmx.de>
 <CAB6yy37-_aC83yS5JaaAbX4-qKWko-pjqSRaipZ3reVnMD=aAg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CAB6yy37-_aC83yS5JaaAbX4-qKWko-pjqSRaipZ3reVnMD=aAg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jul 19, 2014 at 11:23:59AM +0800, Kinglong Mee wrote:
> On Sat, Jul 19, 2014 at 12:50 AM, Toralf Förster <toralf.foerster@gmx.de> wrote:
> > On 07/18/2014 06:22 PM, Toralf Förster wrote:
> >> I can now try with kzalloc, but due to the nature of this issue I think, that the absence of this crash - even after 2-3 hours - doesn't mean by 100%, that kzalloc fixed it, or ?
> >
> > Well, next crash (with kzalloc patch) happened after 20 minutes ...
> 
> Maybe I have found the problem.
> The stateid and denied are defined as an union as,
> fs/nfsd/xdr4.h
> 145 struct nfsd4_lock_denied {
> 146         clientid_t      ld_clientid;
> 147         struct xdr_netobj       ld_owner;
> 148         u64             ld_start;
> 149         u64             ld_length;
> 150         u32             ld_type;
> 151 };
> 152
> 153 struct nfsd4_lock {
> ... ...
> 174         /* response */
> 175         union {
> 176                 struct {
> 177                         stateid_t               stateid;
> 178                 } ok;
> 179                 struct nfsd4_lock_denied        denied;
> 180         } u;
> 
>  30 struct xdr_netobj {
>  31         unsigned int            len;
>  32         u8 *                    data;
>  33 };
> 
> sizeof(stateid_t) = 16, sizeof(clientid_t) = 8,
> sizeof(struct xdr_netobj) = 16, (on x86_x64 platform),
> sizeof(struct xdr_netobj) = 8,  (on i686 platform)
> 
> Lock file success, nfsd will copy stateid to the union, but the value
> also influence denied.
> If on x86_64 platform, only influence the len in xdr_netobj,
> but on i686 platform, will influence the len and the data in xdr_netobj.
> So, the problem only appears on i686 platform.

Oh, great catch, thanks.  Sounds like that would explain all of Toralf's
results.

I'll include this explanation with your original patch and submit it for
3.16.

--b.
