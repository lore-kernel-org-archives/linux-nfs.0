Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f169.google.com ([209.85.212.169]:34291 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756253AbaGSDYB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jul 2014 23:24:01 -0400
Received: by mail-wi0-f169.google.com with SMTP id n3so1951425wiv.4
        for <linux-nfs@vger.kernel.org>; Fri, 18 Jul 2014 20:24:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53C9505D.80601@gmx.de>
References: <53C10EAA.2000802@gmx.de>
	<53C12A93.3040803@gmail.com>
	<20140716185724.GC2397@fieldses.org>
	<20140717202721.GG30442@fieldses.org>
	<53C949DC.5060008@gmx.de>
	<53C9505D.80601@gmx.de>
Date: Sat, 19 Jul 2014 11:23:59 +0800
Message-ID: <CAB6yy37-_aC83yS5JaaAbX4-qKWko-pjqSRaipZ3reVnMD=aAg@mail.gmail.com>
Subject: Re: fuzz tested user mode linux crashed in NFS code path
From: Kinglong Mee <kinglongmee@gmail.com>
To: =?UTF-8?Q?Toralf_F=C3=B6rster?= <toralf.foerster@gmx.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jul 19, 2014 at 12:50 AM, Toralf Förster <toralf.foerster@gmx.de> wrote:
> On 07/18/2014 06:22 PM, Toralf Förster wrote:
>> I can now try with kzalloc, but due to the nature of this issue I think, that the absence of this crash - even after 2-3 hours - doesn't mean by 100%, that kzalloc fixed it, or ?
>
> Well, next crash (with kzalloc patch) happened after 20 minutes ...

Maybe I have found the problem.
The stateid and denied are defined as an union as,
fs/nfsd/xdr4.h
145 struct nfsd4_lock_denied {
146         clientid_t      ld_clientid;
147         struct xdr_netobj       ld_owner;
148         u64             ld_start;
149         u64             ld_length;
150         u32             ld_type;
151 };
152
153 struct nfsd4_lock {
... ...
174         /* response */
175         union {
176                 struct {
177                         stateid_t               stateid;
178                 } ok;
179                 struct nfsd4_lock_denied        denied;
180         } u;

 30 struct xdr_netobj {
 31         unsigned int            len;
 32         u8 *                    data;
 33 };

sizeof(stateid_t) = 16, sizeof(clientid_t) = 8,
sizeof(struct xdr_netobj) = 16, (on x86_x64 platform),
sizeof(struct xdr_netobj) = 8,  (on i686 platform)

Lock file success, nfsd will copy stateid to the union, but the value
also influence denied.
If on x86_64 platform, only influence the len in xdr_netobj,
but on i686 platform, will influence the len and the data in xdr_netobj.
So, the problem only appears on i686 platform.

thanks,
Kinglong Mee
